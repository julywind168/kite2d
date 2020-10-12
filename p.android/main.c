#include <android_native_app_glue.h>
#include <jni.h>
#include <EGL/egl.h>

#include "common.h"
#include "game.h"
#include "asset_helper.h"

#define UPDATE_INTERVAL 16666   // 1.6666 ms
#define MIN_SLEEP_TIME 100      // 0.1 ms

static u_long
get_utime() {
    static struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec * 1000000 + tv.tv_usec;
}


struct engine {
    struct android_app* app;
    struct game *game;
    bool run;

    EGLConfig config;
    EGLDisplay display;
    EGLSurface surface;
    EGLContext context;
};

static void
engine_init_display(struct engine *engine) {
    const EGLint attribs[] = {
            EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT,
            EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
            EGL_BLUE_SIZE, 8,
            EGL_GREEN_SIZE, 8,
            EGL_RED_SIZE, 8,
            EGL_NONE
    };
    const EGLint context_attrib_list[] = {
            EGL_CONTEXT_CLIENT_VERSION, 2,
            EGL_NONE
    };
    EGLint w, h, format;
    EGLint numConfigs;
    EGLConfig config = NULL;
    EGLSurface surface;
    EGLContext context;
    EGLDisplay display = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    eglInitialize(display, NULL, NULL);
    eglChooseConfig(display, attribs, &config,1, &numConfigs);
    if (config == NULL) {
        LOG("Unable to initialize EGLConfig");
        return;
    }
    eglGetConfigAttrib(display, config, EGL_NATIVE_VISUAL_ID, &format);
    surface = eglCreateWindowSurface(display, config, engine->app->window, NULL);
    context = eglCreateContext(display, config, NULL, context_attrib_list);
    if (eglMakeCurrent(display, surface, surface, context) == EGL_FALSE) {
        LOG("Unable to eglMakeCurrent");
        return;
    }
    eglQuerySurface(display, surface, EGL_WIDTH, &w);
    eglQuerySurface(display, surface, EGL_HEIGHT, &h);

    engine->config = config;
    engine->display = display;
    engine->context = context;
    engine->surface = surface;

    engine->game->init(w, h);
    LOG("INIT OK, GL_VERSION: %s", glGetString(GL_VERSION));
}

static void
engine_init_window(struct engine *engine) {
    if (engine->surface != EGL_NO_SURFACE) {
        eglDestroySurface(engine->display, engine->surface);
    }
    engine->surface = eglCreateWindowSurface(engine->display, engine->config, engine->app->window, NULL);
    if (eglMakeCurrent(engine->display, engine->surface, engine->surface, engine->context) == EGL_FALSE) {
        LOG("Unable to eglMakeCurrent on init window");
    }
}

static void
engine_exit(struct engine *engine) {
    if (engine->display != EGL_NO_DISPLAY) {
        eglMakeCurrent(engine->display, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
        if (engine->context != EGL_NO_CONTEXT) {
            eglDestroyContext(engine->display, engine->context);
        }
        if (engine->surface != EGL_NO_SURFACE) {
            eglDestroySurface(engine->display, engine->surface);
        }
        eglTerminate(engine->display);
    }
    engine->display = EGL_NO_DISPLAY;
    engine->context = EGL_NO_CONTEXT;
    engine->surface = EGL_NO_SURFACE;
    engine->game->exit();
    engine->game->destroy();
}

static void
engine_draw_frame(struct engine* engine, float dt) {
    engine->game->draw(dt);
    eglSwapBuffers(engine->display, engine->surface);
}


static int32_t
handle_input(struct android_app* app, AInputEvent* event) {
    struct engine *engine = (struct engine*)app->userData;
    int32_t action;
    float x, y;
    if (AInputEvent_getType(event) == AINPUT_EVENT_TYPE_MOTION) {
        action = AMotionEvent_getAction(event);
        x = AMotionEvent_getX(event, 0);
        y = AMotionEvent_getY(event, 0);
        switch (action & AMOTION_EVENT_ACTION_MASK) {
            case AMOTION_EVENT_ACTION_DOWN:
                engine->game->on_mouse(MOUSE_PRESS, x, y, MOUSE_LEFT);
                break;
            case AMOTION_EVENT_ACTION_UP:
                engine->game->on_mouse(MOUSE_RELEASE, x, y, MOUSE_LEFT);
                break;
            case AMOTION_EVENT_ACTION_MOVE:
                engine->game->on_mouse(MOUSE_MOVE, x, y, MOUSE_LEFT);
                break;
            default:
                break;
        }
        return 1;
    }
    return 0;
}

static void
handle_cmd(struct android_app* app, int32_t cmd) {
    struct engine *engine = (struct engine *)app->userData;
    switch (cmd) {
        case APP_CMD_DESTROY:
            engine->run = false;
            break;
        case APP_CMD_INIT_WINDOW:
            if (engine->app->window) {
                if (engine->display == NULL) {
                    engine_init_display(engine);
                } else {
                    engine_init_window(engine);
                }
                engine->run = true;
            }
            break;
        case APP_CMD_TERM_WINDOW:
            engine->run = false;
            break;
        case APP_CMD_GAINED_FOCUS:
            engine->game->on_resume();
            break;
        case APP_CMD_LOST_FOCUS:
            engine->game->on_pause();
            break;
        default:
            break;
    }
}

void android_main(struct android_app* state) {
    const char *gamedir;
    struct engine engine;
    gamedir = state->activity->internalDataPath;

    copy_assets_on_first(state->activity->assetManager, gamedir);

    memset(&engine, 0, sizeof(struct engine));
    state->userData = &engine;
    state->onAppCmd = handle_cmd;
    state->onInputEvent = handle_input;
    engine.run = false;
    engine.app = state;

    engine.game = create_game(gamedir, "device", "android");
    
    u_long last, now, dt, frame_time;
    u_long rest = (u_long) 10000;
    last = get_utime();
    while (true) {
        int events;
        struct android_poll_source* source;

        while(ALooper_pollAll(0, NULL, &events, (void **)&source) > 0) {
            if (source) {
                source->process(state, source);
            }
            if (state->destroyRequested) {
                engine_exit(&engine);
                return;
            }
        }

        if (engine.run) {
            usleep(rest);
            now = get_utime();
            dt = now - last;
            last = now;
            engine_draw_frame(&engine, (float)dt/1000000);
            frame_time = get_utime() - last;
            if (frame_time >= UPDATE_INTERVAL - MIN_SLEEP_TIME) {
                rest = MIN_SLEEP_TIME;
            } else {
                rest = UPDATE_INTERVAL - frame_time;
            }
        } else {
            usleep(100000);
        }
    }
}