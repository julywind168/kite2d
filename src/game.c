#include "game.h"

#include "lkite.h"
#include "lgraphics.h"
#include "lsprite2d.h"
#include "lmatrix.h"
#include "lprogram.h"
#include "laudio.h"


struct game *G = NULL;


void
game_on_window_resize(int width, int height) {
	lua_State *L = G->L;
	G->width = width;
	G->height = height;
	G->renderer->on_window_resize(width, height);
	lua_pushvalue(L, KITE_RESIZE);
	lua_pushinteger(L, width);
	lua_pushinteger(L, height);
	lua_call(L, 2, 0);
}


void
game_on_resume() {
	lua_State *L = G->L;
	lua_pushvalue(L, KITE_RESUME);
	lua_call(L, 0, 0);
}


void
game_on_pause() {
	lua_State *L = G->L;
	lua_pushvalue(L, KITE_PAUSE);
	lua_call(L, 0, 0);
}


void
game_on_scroll(double ox, double oy) {
	lua_State *L = G->L;
	lua_pushvalue(L, KITE_SCROLL);
	lua_pushnumber(L, ox);
	lua_pushnumber(L, oy);
	lua_call(L, 2, 0);
}

void
game_on_textinput(uint32_t code) {
	lua_State *L = G->L;
	lua_pushvalue(L, KITE_TEXTINPUT);
	lua_pushinteger(L, code);
	lua_call(L, 1, 0);
}


void
game_on_keyboard(int type, int code) {
	lua_State *L = G->L;
	lua_pushvalue(L, KITE_KEYBOARD);
	lua_pushinteger(L, type);
	lua_pushinteger(L, code);
	lua_call(L, 2, 0);
}


void
game_on_mouse(int type, int x, int y, int who) {
	lua_State *L = G->L;
	lua_pushvalue(L, KITE_MOUSE);
	lua_pushinteger(L, type);
	lua_pushinteger(L, x);
	lua_pushinteger(L, G->height - y);
	lua_pushinteger(L, who);
	lua_call(L, 4, 0);
}


void
lua_update(lua_State *L, float dt) {
	lua_pushvalue(L, KITE_UPDATE);
	lua_pushnumber(L, dt);
	lua_call(L, 1, 0);
}


void
lua_draw(lua_State *L) {
	lua_pushvalue(L, KITE_DRAW);
	lua_call(L, 0, 0);
}


void
game_draw(float dt) {
	lua_State *L = G->L;

	lua_update(L, dt);
	G->renderer->draw_start();
	lua_draw(L);
	G->drawcall = G->renderer->draw_end();
}


void
game_exit() {
	lua_State *L = G->L;
	lua_pushvalue(L, KITE_EXIT);
	lua_call(L, 0, 0);
}


void
game_destroy() {
	if(G->renderer)
		G->renderer->destroy();
	if (G->audio)
		G->audio->destroy();
	free(G->gamedir);
	free(G);
}


/**************************************** game init ****************************************/

int
load_lua_main(lua_State *L, const char *gamedir) {
	int n = strlen(gamedir);
	char filename[n+10];
	strcpy(filename, gamedir);
	if (filename[n-1] == '/')
		strcpy(filename + strlen(gamedir), "main.lua");
	else
		strcpy(filename + strlen(gamedir), "/main.lua");

	if (luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0)) {
		LOG("%s\n", lua_tostring(L, -1));
		return 1;
	}

	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_UPDATE");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_DRAW");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_MOUSE");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_KEYBOARD");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_TEXTINPUT");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_PAUSE");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_RESUME");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_SCROLL");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_RESIZE");
	lua_getfield(L, LUA_REGISTRYINDEX, "KITE_EXIT");
	return 0;
}


bool
game_init(uint32_t width, uint32_t height) {
	G->width = width;
	G->height = height;

	G->renderer = create_renderer(width, height);
	G->audio = create_audio();
	if ((G->renderer == NULL) || (G->audio == NULL) || load_lua_main(G->L, G->gamedir)) {
		game_destroy();
		return false;
	}
	return true;
}

/**************************************** create game ****************************************/

int
load_conf(lua_State *L) {
	const char *gamedir = G->gamedir;

	int n = strlen(gamedir);
	char filename[n+12];
	strcpy(filename, gamedir);
	
	if (filename[n-1] == '/')
		strcpy(filename + strlen(gamedir), "config.lua");
	else
		strcpy(filename + strlen(gamedir), "/config.lua");

	if (luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0)) {
		LOG("%s\n", lua_tostring(L, -1));
		return 1;
	}

	// load conf from application table
	const char *title;
	const char *icon;
	uint32_t width, height;
	bool fullscreen;

	// app conf
	lua_getglobal(L, "application");

	// window conf
	lua_pushliteral(L, "window");
	lua_gettable(L, -2);

	lua_pushliteral(L, "width");
	lua_gettable(L, -2);
	width = lua_tointeger(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "height");
	lua_gettable(L, -2);
	height = lua_tointeger(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "title");
	lua_gettable(L, -2);
	title = lua_tostring(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "icon");
	lua_gettable(L, -2);
	icon = lua_tostring(L, -1);
	lua_pop(L, 1);

	lua_pushliteral(L, "fullscreen");
	lua_gettable(L, -2);
	fullscreen = lua_toboolean(L, -1);
	lua_pop(L, 3);

	G->conf.window.width = width;
	G->conf.window.height = height;
	G->conf.window.fullscreen = fullscreen;
	G->conf.window.title = title;
	G->conf.window.icon = icon;
	return 0;
}


lua_State *
create_lua_and_load_conf() {
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	luaL_requiref(L, "kite.core", lib_kite, 0);
	luaL_requiref(L, "graphics.core", lib_graphics, 0);
	luaL_requiref(L, "sprite2d.core", lib_sprite2d, 0);
	luaL_requiref(L, "matrix.core", lib_matrix, 0);
	luaL_requiref(L, "program.core", lib_program, 0);
	luaL_requiref(L, "audio.core", lib_audio, 0);
	lua_pop(L, 6);

	if (load_conf(L)) {
		lua_close(L);
		return NULL;
	}
	return L;
}


char *
copy_gamedir(const char *gamedir) {
	char *dir;
	int n = strlen(gamedir);
	if (gamedir[n - 1] == '/'){
		n = n - 1;
	}

	dir = malloc(n + 1);
	memcpy(dir, gamedir, n);
	dir[n] = '\0';
	return dir;
}


struct game *
create_game(const char *gamedir, const char *environment, const char *platform) {
	G = malloc(sizeof(struct game));
	memset(G, 0, sizeof(struct game));

	G->gamedir = copy_gamedir(gamedir);
	G->environment = environment;
	G->platform = platform;
	G->drawcall = 0;
	G->L = create_lua_and_load_conf();
	if (G->L == NULL) {
		free(G->gamedir);
		free(G);
		return NULL;
	}

	G->init = game_init;
	G->exit = game_exit;
	G->draw = game_draw;
	G->on_mouse = game_on_mouse;
	G->on_keyboard = game_on_keyboard;
	G->on_scroll = game_on_scroll;
	G->on_textinput = game_on_textinput;
	G->on_pause = game_on_pause;
	G->on_resume = game_on_resume;
	G->on_resize = game_on_window_resize;
	G->destroy = game_destroy;
	return G;
}
