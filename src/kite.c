#include "kite.h"
#include "game.h"
#include "lkite.h"
#include "lgraphics.h"
#include "lfont.h"
#include "laudio.h"

#define KITE_UPDATE 1
#define KITE_DRAW 2
#define KITE_MOUSE 3
#define KITE_KEYBOARD 4
#define KITE_MESSAGE 5
#define KITE_PAUSE 6
#define KITE_RESUME 7
#define KITE_SCROLL 8
#define KITE_EXIT 9

#define MOUSE_PRESS 1
#define MOUSE_RELEASE 2
#define MOUSE_MOVE 3
#define MOUSE_ENTER 4
#define MOUSE_LEAVE 5

#define KEY_PRESS 1
#define KEY_RELEASE 2


static Kite *kite;
extern Game * G;
/////////////////////////////////////////////////////
static void 
on_kite_error(lua_State *L) {
	luaL_traceback(L, L, lua_tostring(L, -1), 1);
	fprintf(stderr, "%s\n", lua_tostring(L, -1));
	glfwSetWindowShouldClose(G->window->handle, 1);
}


void
kite_exit() {
	lua_State *L = kite->L;
	lua_pushvalue(L, KITE_EXIT);
	if (lua_pcall(L, 0, 0, 0) != LUA_OK) on_kite_error(L);
}


void
kite_scroll(GLFWwindow *window, double ox, double oy) {
	lua_State *L = kite->L;
	lua_pushvalue(L, KITE_SCROLL);
	lua_pushnumber(L, ox);
	lua_pushnumber(L, oy);
	if (lua_pcall(L, 2, 0, 0) != LUA_OK) on_kite_error(L);
}


void
kite_message(GLFWwindow *window, uint32_t code) {
	lua_State *L = kite->L;
	lua_pushvalue(L, KITE_MESSAGE);
	lua_pushinteger(L, code);
	if (lua_pcall(L, 1, 0, 0) != LUA_OK) on_kite_error(L);
}


void
kite_keyboard(GLFWwindow *window, int key, int scancode, int action, int mods) {
	lua_State *L = kite->L;
	if (action != 2) {
		if (action == 0)
			action = KEY_RELEASE;
		lua_pushvalue(L, KITE_KEYBOARD);
		lua_pushinteger(L, key);
		lua_pushinteger(L, action);
		if (lua_pcall(L, 2, 0, 0) != LUA_OK) on_kite_error(L);
	}
}

void
kite_mouse(GLFWwindow* window, int button, int action, int mods) {
	
	lua_State *L = kite->L;
	double x, y;

	glfwGetCursorPos(window, &x, &y);
	x = x + 1.f;
	y = G->window->height - (float)y;
	
	button = button + 1;
	if (action == 0)
		action = MOUSE_RELEASE;
	lua_pushvalue(L, KITE_MOUSE);
	lua_pushinteger(L, action);
	lua_pushinteger(L, (int)x);
	lua_pushinteger(L, (int)y);

	lua_pushinteger(L, button);
	if (lua_pcall(L, 4, 0, 0) != LUA_OK) on_kite_error(L);
}

void 
_kite_cursor_enter(GLFWwindow* window, int entered) {
	lua_State *L = kite->L;
	if (entered)
		entered = MOUSE_ENTER;
	else
		entered = MOUSE_LEAVE;
	lua_pushvalue(L, KITE_MOUSE);
	lua_pushinteger(L, entered);
	if (lua_pcall(L, 1, 0, 0) != LUA_OK) on_kite_error(L);
}

void
_kite_cursor_move(GLFWwindow* window, double x, double y) {
	lua_State *L = kite->L;
	x = x + 1.f;
	y = G->window->height - (float)y;
	lua_pushvalue(L, KITE_MOUSE);
	lua_pushinteger(L, MOUSE_MOVE);
	lua_pushinteger(L, (int)x);
	lua_pushinteger(L, (int)y);
	if (lua_pcall(L, 3, 0, 0) != LUA_OK) on_kite_error(L);
}


void
kite_update(double dt) {
	lua_State *L = kite->L;
	lua_pushvalue(L, KITE_UPDATE);
	lua_pushnumber(L, dt);
	if (lua_pcall(L, 1, 0, 0) != LUA_OK) on_kite_error(L);
}


void
kite_draw() {
	lua_State *L = kite->L;
	lua_pushvalue(L, KITE_DRAW);
	if (lua_pcall(L, 0, 0, 0) != LUA_OK) on_kite_error(L);
}
/////////////////////////////////////////////////////
int kite_load() {
	lua_State *L = kite->L;
	if (lua_pcall(L, 0, 0, 0)) {
		luaL_traceback(L, L, lua_tostring(L, -1), 1);
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_pop(L, 2);
		return 1;
	}
	ASSERT(lua_gettop(L) == 0, "bad lua stack");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_UPDATE");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_DRAW");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_MOUSE");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_KEYBOARD");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_MESSAGE");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_PAUSE");		
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_RESUME");	
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_SCROLL");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_EXIT");
	return 0;
}


 
static int
load_main(lua_State *L, const char *gamedir) {
	int n = strlen(gamedir);
	char filename[n+10];
	strcpy(filename, gamedir);
	if (filename[n-1] == '/')
		strcpy(filename + strlen(gamedir), "main.lua");
	else
		strcpy(filename + strlen(gamedir), "/main.lua");

	if (luaL_loadfile(L, filename)) {
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		return 1;
	}
	return 0;
}


void
load_window_conf(lua_State *L) {
	const char *title;
	float width, height;
	bool fullscreen;

	lua_getglobal(L, "application");
	lua_pushliteral(L, "window");
	lua_gettable(L, -2);

	lua_pushliteral(L, "width");
	lua_gettable(L, -2);
	width = luaL_optnumber(L, -1, 0.f);
	lua_pop(L, 1);

	lua_pushliteral(L, "height");
	lua_gettable(L, -2);
	height = luaL_optnumber(L, -1, 0.f);
	lua_pop(L, 1);

	lua_pushliteral(L, "title");
	lua_gettable(L, -2);
	title = lua_tostring(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "fullscreen");
	lua_gettable(L, -2);
	fullscreen = lua_toboolean(L, -1);
	lua_pop(L, 3);

	kite->conf.window.width = width;
	kite->conf.window.height = height;
	kite->conf.window.fullscreen = fullscreen;
	kite->conf.window.title = malloc(strlen(title) + 1);
	strcpy(kite->conf.window.title, title);
}


static int
load_conf(lua_State *L, const char *gamedir) {
	int n = strlen(gamedir);
	char filename[n+12];
	strcpy(filename, gamedir);
	
	if (filename[n-1] == '/')
		strcpy(filename + strlen(gamedir), "config.lua");
	else
		strcpy(filename + strlen(gamedir), "/config.lua");

	if (luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0)) {
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		return 1;
	}

	load_window_conf(L);
	return 0;
}


static int
kite_init(const char *gamedir) {
	lua_State *L = kite->L;
	luaL_openlibs(L);
	luaL_requiref(L, "kite.core", lib_kite, 0);
	luaL_requiref(L, "graphics.core", lib_graphics, 0);
	luaL_requiref(L, "font.core", lib_font, 0);
	luaL_requiref(L, "audio.core", lib_audio, 0);
	lua_pop(L, 4);
	if (load_conf(L, gamedir) || load_main(L, gamedir)) {
		return 1;
	}
	return 0;
}


void
kite_destroy() {
	lua_close(kite->L);
	free(kite->conf.window.title);
	free(kite);
}


Kite *
create_kite(const char *gamedir) {
	kite = malloc(sizeof(Kite));
	kite->L = luaL_newstate();
	kite->load = kite_load;
	kite->update = kite_update;
	kite->draw = kite_draw;
	kite->_cursor_move = _kite_cursor_move;
	kite->_cursor_enter = _kite_cursor_enter; 
	kite->mouse = kite_mouse;
	kite->keyboard = kite_keyboard;
	kite->message = kite_message;
	kite->scroll = kite_scroll;
	kite->exit = kite_exit;

	kite->destroy = kite_destroy;
	if (kite_init(gamedir)) {
		lua_close(kite->L);
		free(kite);
		return NULL;
	}
	return kite;
}