#include "lkite.h"
#include "game.h"

#define VERSION "0.5 (dev)"


extern struct game *G;



static int
llog(lua_State *L) {
	#ifdef __ANDROID__
		const char *string = lua_tostring(L, 1);
		LOG("%s\n", string);
	#endif
	return 0;
}


static int
lwindow_height(lua_State *L) {
	lua_pushinteger(L, G->height);
	return 1;
}


static int
lwindow_width(lua_State *L) {
	lua_pushinteger(L, G->width);
	return 1;
}


static int
ldrawcall(lua_State *L) {
	lua_pushinteger(L, G->drawcall);
	return 1;
}


static int
linject(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_pushstring(L, "update");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_UPDATE");
	lua_pushstring(L, "draw");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_DRAW");
	lua_pushstring(L, "mouse");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_MOUSE");
	lua_pushstring(L, "keyboard");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_KEYBOARD");
	lua_pushstring(L, "textinput");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_TEXTINPUT");
	lua_pushstring(L, "pause");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_PAUSE");
	lua_pushstring(L, "resume");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_RESUME");
	lua_pushstring(L, "scroll");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_SCROLL");
	lua_pushstring(L, "resize");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_RESIZE");
	lua_pushstring(L, "exit");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_EXIT");
	lua_pop(L, 1);
	return 0;
}


static int
lversion(lua_State *L) {
	lua_pushstring(L, VERSION);
	return 1;
}


int
lib_kite(lua_State *L)
{
	luaL_Reg l[] = {
			{"log", llog},
			{"window_height", lwindow_height},
			{"window_width", lwindow_width},
			{"drawcall", ldrawcall},
			{"inject", linject},
			{"version", lversion},
			{NULL, NULL}
	};
	luaL_newlib(L, l);
	lua_pushstring(L, G->gamedir);
	lua_setfield(L, -2, "gamedir");

	lua_pushstring(L, G->platform);
	lua_setfield(L, -2, "platform");
	return 1;
}