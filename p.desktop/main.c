#include "common.h"
#include "game.h"
#include "util.h"

struct game *game;


void
handle_resize(GLFWwindow *hwnd, int width, int height) {
	game->on_resize(width, height);
}


void
handle_iconify(GLFWwindow *hwnd, int iconified) {
	if (iconified)
		game->on_pause();
	else
		game->on_resume();
}


void
handle_scroll(GLFWwindow *hwnd, double ox, double oy) {
	game->on_scroll(ox, oy);
}


void
handle_textinput(GLFWwindow *hwnd, uint32_t code) {
	game->on_textinput(code);
}


void 
handle_cursor_enter(GLFWwindow* hwnd, int entered) {
	if (entered)
		entered = MOUSE_ENTER;
	else
		entered = MOUSE_LEAVE;
	game->on_mouse(entered, 0, 0, 0);
}


void
handle_cursor_move(GLFWwindow* hwnd, double x, double y) {
	x = x + 1.f;
	y = y + 1.f;
	game->on_mouse(MOUSE_MOVE, (int)x, (int)y, 0);
}


void
handle_mouse(GLFWwindow* hwnd, int button, int action, int mods) {
	double x, y;
	glfwGetCursorPos(hwnd, &x, &y);
	x = x + 1.f;
	y = y + 1.f;
	button = button + 1;
	if (action == 0)
		action = MOUSE_RELEASE;
	game->on_mouse(action, (int)x, (int)y, button);
}


void
handle_keyboard(GLFWwindow *hwnd, int key, int scancode, int action, int mods) {
	if (action != 2) {
		if (action == 0)
			action = KEY_RELEASE;
		game->on_keyboard(action, key);
	}
}


static GLFWmonitor *
get_monitor() {
	int count = 0;
	GLFWmonitor **monitor = glfwGetMonitors(&count);
	assert(count > 0);
	return monitor[0];
}


int
main(int argc, char const *argv[])
{
	GLFWwindow *hwnd;
	GLFWmonitor *monitor;
	const GLFWvidmode *display;
	const char *title;
	const char *icon_path;
	uint32_t width, height;
	bool fullscreen;
	double now, last, dt;

	if (argc != 2) {
		LOG("usage ./kite.exe 'gamedir'\n");
		return 1;
	}

	game = create_game(argv[1], "simulator", "windows");
	

	width = game->conf.window.width;
	height = game->conf.window.height;
	title = game->conf.window.title;
	icon_path = game->conf.window.icon;
	fullscreen = game->conf.window.fullscreen;

	// create window
	if (!glfwInit()) {
		LOG("failed to init glfw\n");
		return 1;
	}
	glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	monitor = get_monitor();
	display = glfwGetVideoMode(monitor);
	glfwWindowHint(GLFW_RED_BITS, display->redBits);
	glfwWindowHint(GLFW_GREEN_BITS, display->greenBits);
	glfwWindowHint(GLFW_BLUE_BITS, display->blueBits);
	glfwWindowHint(GLFW_REFRESH_RATE, display->refreshRate);

	if (fullscreen) {
		width = display->width;
		height = display->height;
		hwnd = glfwCreateWindow(width, height, title, monitor, NULL);
	} else {
		hwnd = glfwCreateWindow(width, height, title, NULL, NULL);
		glfwSetWindowPos(hwnd, display->width/2 - width/2, display->height/2 - height/2);
	}
	if (!hwnd) {
		LOG("failed to create window\n");
		return 1;
	}

	// set icon
	if (icon_path) {
		GLFWimage icon;
		icon.pixels = load_image(icon_path, &icon.width, &icon.height, NULL, false);
		glfwSetWindowIcon(hwnd, 1, &icon);
		destroy_image(icon.pixels);
	}
	
	//init
	glfwMakeContextCurrent(hwnd);
	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
		LOG("failed to init glad\n");
		return 1;
	}
	glfwSwapInterval(1);

	game->hwnd = hwnd;
	game->init(width, height);

	// set callback
	glfwSetKeyCallback(hwnd, handle_keyboard);
	glfwSetMouseButtonCallback(hwnd, handle_mouse);
	glfwSetCursorPosCallback(hwnd, handle_cursor_move);
	glfwSetCursorEnterCallback(hwnd, handle_cursor_enter);
	glfwSetCharCallback(hwnd, handle_textinput);
	glfwSetScrollCallback(hwnd, handle_scroll);
	glfwSetWindowIconifyCallback(hwnd, handle_iconify);
	glfwSetFramebufferSizeCallback(hwnd, handle_resize);

	// mainloop
	last = glfwGetTime();
	
	while(!glfwWindowShouldClose(hwnd)) {
		now = glfwGetTime();
		dt = now - last;
		last = now;

		game->draw(dt);
		glfwPollEvents();
		glfwSwapBuffers(hwnd);
	}

	game->exit();
	game->destroy();

	return 0;
}