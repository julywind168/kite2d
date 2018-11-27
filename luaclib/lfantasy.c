#include "lfantasy.h"
#include "game.h"


extern Game * G;


static int
ltime(lua_State *L) {
    lua_pushnumber(L, G->time);
    return 1;
}


static int
linject(lua_State *L) {
	luaL_checktype(L, 1, LUA_TTABLE);
	luaL_checktype(L, 2, LUA_TTABLE);
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
	lua_pushstring(L, "message");
	lua_gettable(L, -2);
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_MESSAGE");
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
	lua_setfield(L, LUA_REGISTRYINDEX, "FANTASY_CONFIG");
	return 0;
}


int
lib_fantasy(lua_State *L)
{
	luaL_Reg l[] = {
        {"time", ltime},
        {"inject", linject},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}