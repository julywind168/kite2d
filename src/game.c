#include "util.h"
#include "game.h"
#include "lsystem.h"
#include "lgraphics.h"
#include "lfantasy.h"
#include "lwindow.h"
#include "lcamera.h"

#define FANTASY_INIT 1
#define FANTASY_UPDATE 2
#define FANTASY_DRAW 3
#define FANTASY_MOUSE 4
#define FANTASY_KEYBOARD 5
#define FANTASY_PAUSE 6
#define FANTASY_RESUME 7
#define FANTASY_EXIT 8


#define MOUSE_PRESS 1
#define MOUSE_RELEASE 2
#define MOUSE_MOVE 3

#define KEY_PRESS 1
#define KEY_RELEASE 2

Game *G;


void
fantasy_keyboard(GLFWwindow* window, int key, int scancode, int action, int mods) {

	lua_State *L = G->L;

	if (action != 2) {
		if (action == 0)
			action = KEY_RELEASE;
		lua_pushvalue(L, FANTASY_KEYBOARD);
		lua_pushinteger(L, key);
		lua_pushinteger(L, action);
		if (lua_pcall(L, 2, 0, 0) != LUA_OK) {
			fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
			lua_pop(L, 1);
		}
	}
}

void
fantasy_mouse(GLFWwindow* window, int button, int action, int mods) {
	
	lua_State *L = G->L;
	double x, y;

	glfwGetCursorPos(window, &x, &y);

	button = button + 1;
	if (action == 0)
		action = MOUSE_RELEASE;
	lua_pushvalue(L, FANTASY_MOUSE);
	lua_pushinteger(L, action);
	lua_pushinteger(L, (int)x);
	lua_pushinteger(L, (int)y);

	lua_pushinteger(L, button);
	if (lua_pcall(L, 4, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}

void
fantasy_cursor(GLFWwindow* window, double x, double y) {
	lua_State *L = G->L;
	lua_pushvalue(L, FANTASY_MOUSE);
	lua_pushinteger(L, MOUSE_MOVE);
	lua_pushinteger(L, (int)x);
	lua_pushinteger(L, (int)y);
	if (lua_pcall(L, 3, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}

void
fantasy_exit() {
	lua_State *L = G->L;
	lua_pushvalue(L, FANTASY_EXIT);
	if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}

void
fantasy_update(double dt) {
	lua_State *L = G->L;
	lua_pushvalue(L, FANTASY_UPDATE);
	lua_pushnumber(L, dt);
	if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}

void
fantasy_draw() {
	lua_State *L = G->L;
	lua_pushvalue(L, FANTASY_DRAW);
	if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}

void
fantasy_init() {
	lua_State *L = G->L;
	lua_pushvalue(L, FANTASY_INIT);
	if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}

void
game_start(Game *game) {
	double now, dt;
	GLFWwindow *window = game->win_handle;


	glfwSetKeyCallback(window, fantasy_keyboard);
	glfwSetMouseButtonCallback(window, fantasy_mouse);
	glfwSetCursorPosCallback(window, fantasy_cursor);
	fantasy_init();
	game->time = glfwGetTime();
	while(!glfwWindowShouldClose(window)) {
		
		now = glfwGetTime();
		dt = now - game->time;
		game->time = now;
		fantasy_update(dt);

		//draw start
		glClear(GL_COLOR_BUFFER_BIT);
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		fantasy_draw();

		glfwPollEvents();
		glfwSwapBuffers(window);
	}

	fantasy_exit();
}


void
destroy_game(Game * game) {
	lua_close(game->L);
	glfwTerminate();
	free(game);	
}


int
create_lua(Game *game, const char *filename) {
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);

	luaL_requiref(L, "fantasy.core", lib_fantasy, 0);
	lua_pop(L, 1);
	luaL_requiref(L, "system.core", lib_system, 0);
	lua_pop(L, 1);
	luaL_requiref(L, "graphics.core", lib_graphics, 0);
	lua_pop(L, 1);
	luaL_requiref(L, "window.core", lib_window, 0);
	lua_pop(L, 1);
	luaL_requiref(L, "camera.core", lib_camera, 0);
	lua_pop(L, 1);

	lua_newtable(L);
	lua_setglobal(L, "fantasy");

	int error = luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0);
	if (error) {
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_close(L);
		return 1;
	}

	lua_getglobal(L, "fantasy");

	lua_pushstring(L, "init");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_INIT");
	lua_pushstring(L, "update");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_UPDATE");
	lua_pushstring(L, "draw");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_DRAW");
	lua_pushstring(L, "mouse");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_MOUSE");
	lua_pushstring(L, "keyboard");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_KEYBOARD");
	lua_pushstring(L, "pause");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_PAUSE");
	lua_pushstring(L, "resume");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_RESUME");
	lua_pushstring(L, "exit");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_EXIT");
	lua_pop(L, 1);

	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_INIT");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_UPDATE");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_DRAW");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_MOUSE");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_KEYBOARD");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_PAUSE");		
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_RESUME");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_EXIT");

	game->L = L;
	return 0;
}


static void
init_glfw() {
	glfwInit();
	glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
}


static void
on_window_resize(GLFWwindow *window, int width, int height) {
	printf("window resize %d %d\n", width, height);
	glViewport(0, 0, width, height);
}




int
init_opengl(Game *game) {
	GLuint program, window, camera;
	float camera_x, camera_y;

	lua_State *L = game->L;
	lua_getglobal(L, "fantasy");
	lua_pushliteral(L, "camera");
	lua_gettable(L, -2);
	lua_pushliteral(L, "x");
	lua_gettable(L, -2);
	camera_x = lua_tonumber(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "y");
	lua_gettable(L, -2);
	camera_y = lua_tonumber(L, -1);
	lua_pop(L, 3);

	glfwMakeContextCurrent(game->win_handle);
	if(!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
		fprintf(stderr, "%s\n", "failed to init glad");
		return 1;
	}
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glViewport(0, 0, game->win_width, game->win_height);
	glfwSetFramebufferSizeCallback(game->win_handle, on_window_resize);

	program = create_program();
	glUseProgram(program);
	glUniform1i(glGetUniformLocation(program, "texture0"), 0);

	window = glGetUniformLocation(program, "window");
	camera = glGetUniformLocation(program, "camera");

	glUniform2ui(window, game->win_width, game->win_height);
	glUniform2f(camera, camera_x, camera_y);
	
	game->camera_x = camera_x;
	game->camera_y = camera_y;
	game->program = program;
	game->window = window;
	game->camera = camera;
	return 0;
}


int
create_window(Game *game) {

	const char *title;
	int x, y;
	int width, height, fullscreen;
	GLFWmonitor *monitor0;
	GLFWwindow *window;

	lua_State *L = game->L;
	lua_getglobal(L, "fantasy");
	lua_pushliteral(L, "window");
	lua_gettable(L, -2);

	lua_pushliteral(L, "width");
	lua_gettable(L, -2);
	width = luaL_optinteger(L, -1, 1024);
	lua_pop(L, 1);

	lua_pushliteral(L, "height");
	lua_gettable(L, -2);
	height = luaL_optinteger(L, -1, 768);
	lua_pop(L, 1);

	lua_pushliteral(L, "fullscreen");
	lua_gettable(L, -2);
	fullscreen = lua_toboolean(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "x");
	lua_gettable(L, -2);
	x = luaL_optinteger(L, -1, 0);
	lua_pop(L, 1);

	lua_pushliteral(L, "y");
	lua_gettable(L, -2);
	y = luaL_optinteger(L, -1, 0);
	lua_pop(L, 1);

	lua_pushliteral(L, "title");
	lua_gettable(L, -2);
	title = luaL_optstring(L, -1, "Fantasy");
	lua_pop(L, 3);

	int count;
	GLFWmonitor **monitor =  glfwGetMonitors(&count);
	assert(count > 0);
	monitor0 = monitor[0];

	const GLFWvidmode *display = glfwGetVideoMode(monitor0);

	glfwWindowHint(GLFW_RED_BITS, display->redBits);
	glfwWindowHint(GLFW_GREEN_BITS, display->greenBits);
	glfwWindowHint(GLFW_BLUE_BITS, display->blueBits);
	glfwWindowHint(GLFW_REFRESH_RATE, display->refreshRate);

	if (fullscreen) {
		width = display->width;
		height = display->height;
		window = glfwCreateWindow(width, height, title, monitor0, NULL);
	} else
		window = glfwCreateWindow(width, height, title, NULL, NULL);
	
	if (!window) {
		fprintf(stderr, "%s\n", "failed to create window");
		return 1;
	}

	glfwSetWindowPos(window, display->width/2 + x - width/2, display->height/2 + y - height/2);

	game->display = display;
	game->monitor = monitor0;

	game->win_x = x;
	game->win_y = y;
	game->win_width = width;
	game->win_height = height;
	game->win_handle = window;

	printf("window width:%d height:%d\n", width, height);
	return 0;
}


Game *
create_game(const char *filename) {
	Game *game = malloc(sizeof(Game));

	init_glfw();
	if (create_lua(game, filename)) {
		free(game);
		return NULL;
	}
	printf("create lua success\n");
	if(create_window(game)) {
		destroy_game(game);
		return NULL;
	}
	printf("create window success\n");

	if(init_opengl(game)) {
		destroy_game(game);
		return NULL;
	}
	printf("inti opengl success\n");

	G = game;
	return game;
}