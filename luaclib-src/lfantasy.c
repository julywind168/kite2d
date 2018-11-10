#include "lfantasy.h"
#include "game.h"

extern Game * G;



static int
ltime(lua_State *L) {
    lua_pushnumber(L, G->time);
    return 1;
}



int
lib_fantasy(lua_State *L)
{
	luaL_Reg l[] = {
        {"time", ltime},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}