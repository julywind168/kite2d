#include "fant.h"
#include "lfantasy.h"
#include "lgraphics.h"
#include "lfont.h"

static Fant *fant;

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

/////////////////////////////////////////////////////
void
fant_init() {
	lua_State *L = fant->L;
	lua_pushvalue(L, FANTASY_INIT);
	if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}

void
fant_keyboard(GLFWwindow* window, int key, int scancode, int action, int mods) {
	lua_State *L = fant->L;
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
fant_mouse(GLFWwindow* window, int button, int action, int mods) {
	
	lua_State *L = fant->L;
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
_fant_cursor(GLFWwindow* window, double x, double y) {
	lua_State *L = fant->L;
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
fant_update(double dt) {
	lua_State *L = fant->L;
	lua_pushvalue(L, FANTASY_UPDATE);
	lua_pushnumber(L, dt);
	if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}


void
fant_draw() {
	lua_State *L = fant->L;
	lua_pushvalue(L, FANTASY_DRAW);
	if (lua_pcall(L, 0, 0, 0) != LUA_OK) {
		fprintf(stderr, "lua error: %s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
}
/////////////////////////////////////////////////////

void
load_callback(lua_State *L) {
	ASSERT(lua_gettop(L) == 0, "bad lua stack");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_INIT");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_UPDATE");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_DRAW");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_MOUSE");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_KEYBOARD");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_PAUSE");		
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_RESUME");
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_EXIT");
}


void
load_camera_conf(lua_State *L) {
	float x, y, scale, angle;
	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_CONFIG");
	lua_pushliteral(L, "camera");
	lua_gettable(L, -2);
	
	if lua_isnil(L, -1) {
		x = fant->conf.window.x;
		y = fant->conf.window.y;
		scale = 1.f;
		angle = 0.f;
		lua_pop(L, 2);
	} else {
		lua_pushliteral(L, "x");
		lua_gettable(L, -2);
		x = luaL_optnumber(L, -1, fant->conf.window.x);
		lua_pop(L, 1);

		lua_pushliteral(L, "y");
		lua_gettable(L, -2);
		y = luaL_optnumber(L, -1, fant->conf.window.y);
		lua_pop(L, 1);

		lua_pushliteral(L, "scale");
		lua_gettable(L, -2);
		scale = luaL_optnumber(L, -1, 1.f);
		lua_pop(L, 1);

		lua_pushliteral(L, "angle");
		lua_gettable(L, -2);
		angle = luaL_optnumber(L, -1, 0.f) * (M_PI/180.f);
		lua_pop(L, 3);

		fant->conf.camera.x = x;
		fant->conf.camera.y = y;
		fant->conf.camera.scale = scale;
		fant->conf.camera.angle = angle;
	}
}


void
load_window_conf(lua_State *L) {
	const char *title;
	float x, y, width, height;
	bool fullscreen;

	lua_getfield(L, LUA_REGISTRYINDEX, "FANTASY_CONFIG");
	lua_pushliteral(L, "window");
	lua_gettable(L, -2);
	
	lua_pushliteral(L, "x");
	lua_gettable(L, -2);
	x = lua_tonumber(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "y");
	lua_gettable(L, -2);
	y = lua_tonumber(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "width");
	lua_gettable(L, -2);
	width = lua_tonumber(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "height");
	lua_gettable(L, -2);
	height = lua_tonumber(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "title");
	lua_gettable(L, -2);
	title = lua_tostring(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "fullscreen");
	lua_gettable(L, -2);
	fullscreen = lua_toboolean(L, -1);
	lua_pop(L, 3);

	fant->conf.window.x = x;
	fant->conf.window.y = y;
	fant->conf.window.width = width;
	fant->conf.window.height = height;
	fant->conf.window.fullscreen = fullscreen;
	fant->conf.window.title = malloc(strlen(title) + 1);
	strcpy(fant->conf.window.title, title);
}


void
fant_destroy() {
	lua_close(fant->L);
	free(fant->conf.window.title);
	free(fant);
}


Fant *
create_fant(const char *filename) {
	lua_State *L;
	L = luaL_newstate();
	luaL_openlibs(L);
	luaL_requiref(L, "fantasy.core", lib_fantasy, 0);
	luaL_requiref(L, "graphics.core", lib_graphics, 0);
	luaL_requiref(L, "font.core", lib_font, 0);
	lua_pop(L, 3);

	if(luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0)) {
		fprintf(stderr, "%s\n", lua_tostring(L, -1));
		lua_close(L);
		return NULL;
	}
	
	fant = malloc(sizeof(Fant));
	fant->L = L;

	fant->init = fant_init;
	fant->update = fant_update;
	fant->draw = fant_draw;
	fant->_cursor = _fant_cursor; 
	fant->mouse = fant_mouse;
	fant->keyboard = fant_keyboard;
	fant->destroy = fant_destroy;
	load_window_conf(L);
	load_camera_conf(L);
	load_callback(L);
	return fant;
}