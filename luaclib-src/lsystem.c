#include "lsystem.h"
#include "game.h"

#include <sys/time.h>

static int
ldisplay(lua_State *L)
{
	int count;
    GLFWmonitor **monitor =  glfwGetMonitors(&count);

    lua_newtable(L);
	for(int i=0; i<count; i++){
        const GLFWvidmode *mode = glfwGetVideoMode(monitor[i]);
        lua_newtable(L);

        lua_pushstring(L, "width");
        lua_pushinteger(L, mode->width);
        lua_settable(L, -3);

        lua_pushstring(L, "height");
        lua_pushinteger(L, mode->height);
        lua_settable(L, -3);
        lua_rawseti(L, -2, i+1);
    }
    return 1;
}


int
lib_system(lua_State *L)
{
	luaL_Reg l[] = {
		{"display", ldisplay},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}