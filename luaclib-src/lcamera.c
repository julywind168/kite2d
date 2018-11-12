#include "lcamera.h"
#include "game.h"


extern Game * G;


static int
lupdate_x(lua_State *L) {
	G->camera_x = luaL_checknumber(L, 1);
	glUniform2f(G->camera, G->camera_x, G->camera_y);
	return 0;
}


static int
lupdate_y(lua_State *L) {
	G->camera_y = luaL_checknumber(L, 1);
	glUniform2f(G->camera, G->camera_x, G->camera_y);
	return 0;
}



int
lib_camera(lua_State *L)
{
	luaL_Reg l[] = {
        {"update_x", lupdate_x},
        {"update_y", lupdate_y},
 		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}