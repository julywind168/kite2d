#include "lwindow.h"
#include "game.h"

extern Game * G;


static int
lupdate_x(lua_State *L) {
	int x = luaL_checkinteger(L, 1);
	G->win_x = x;
	glfwSetWindowPos(G->win_handle, G->display->width/2 + G->win_x - G->win_width/2, G->display->height/2 + G->win_y - G->win_height/2);
	return 0;
}


static int
lupdate_y(lua_State *L) {
	int y = luaL_checkinteger(L, 1);
	G->win_y = y;
	glfwSetWindowPos(G->win_handle, G->display->width/2 + G->win_x - G->win_width/2, G->display->height/2 + G->win_y - G->win_height/2);
	return 0;
}


static int
lupdate_width(lua_State *L) {
	uint32_t width = luaL_checkinteger(L, 1);
	G->win_width = width;
	glfwSetWindowSize(G->win_handle, G->win_width, G->win_height);
	glUniform2ui(G->window, G->win_width, G->win_height);
	return 0;
}


static int
lupdate_height(lua_State *L) {
	uint32_t height = luaL_checkinteger(L, 1);
	G->win_height = height;
	glfwSetWindowSize(G->win_handle, G->win_width, G->win_height);
	glUniform2ui(G->window, G->win_width, G->win_height);
	return 0;
}


static int
lupdate_title(lua_State *L) {
	const char *title = luaL_checkstring(L, 1);
	glfwSetWindowTitle(G->win_handle, title);
	return 0;
}


static int
lfullscreen(lua_State *L) {
	glfwSetWindowMonitor(G->win_handle, G->monitor, 0, 0, G->display->width, G->display->height, G->display->refreshRate);
	G->win_width = G->display->width;
	G->win_height = G->display->height;
	glUniform2ui(G->window, G->win_width, G->win_height);

	lua_pushinteger(L, G->win_width);
	lua_pushinteger(L, G->win_height);
	return 2;
}

static int
lcancel_fullscreen(lua_State *L) {
	uint32_t width, height;
	int x, y;
	width = luaL_checkinteger(L, 1);
	height = luaL_checkinteger(L, 2);

	x = G->display->width/2 + G->win_x - width/2;
	y = G->display->height/2 + G->win_y - height/2;

	glfwSetWindowMonitor(G->win_handle, NULL, x, y, width, height, GLFW_DONT_CARE);

	G->win_width = width;
	G->win_height = height;
	glUniform2ui(G->window, G->win_width, G->win_height);
	return 0;
}


int
lib_window(lua_State *L)
{
	luaL_Reg l[] = {
        {"update_x", lupdate_x},
        {"update_y", lupdate_y},
        {"update_width", lupdate_width},
        {"update_height", lupdate_height},
        {"update_title", lupdate_title},
        {"fullscreen", lfullscreen},
        {"cancel_fullscreen", lcancel_fullscreen},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}