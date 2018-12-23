#include "lkite.h"
#include "game.h"

#define VERSION "0.03"

extern Game * G;




static int
lexit(lua_State *L) {
	glfwSetWindowShouldClose(G->window->handle, 1);
	return 1;
}


static int
ldrawcall(lua_State *L) {
	lua_pushinteger(L, G->drawcall);
	return 1;
}


static int
ltime(lua_State *L) {
    lua_pushnumber(L, G->time);
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
	lua_pushstring(L, "message");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_MESSAGE");
	lua_pushstring(L, "pause");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_PAUSE");
	lua_pushstring(L, "resume");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "KITE_RESUME");
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
		{"exit", lexit},
		{"drawcall", ldrawcall},
        {"time", ltime},
        {"inject", linject},
        {"version", lversion},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}