#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#include "lgraphics.h"
#include "lfont.h"
#include "game.h"

extern Game * G;


static void
ROTATE(float x0, float y0, float a, float x1, float y1, float *x, float *y) {
	*x = (x1 - x0)*cos(a) - (y1 - y0)*sin(a) + x0;
	*y = (x1 - x0)*sin(a) + (y1 - y0)*cos(a) + y0;
}


static int
lprint(lua_State *L) {
	Character *ch;
	uint32_t n, color;
	float x0, y0, x, y, w, h, posx, posy, angle;

	n = luaL_len(L, 1);
	x0 = floor(luaL_checknumber(L, 2));
	y0 = floor(luaL_checknumber(L, 3));
	x = floor(luaL_checknumber(L, 4));
	y = floor(luaL_checknumber(L, 5));
	angle = luaL_checknumber(L, 6) * (M_PI/180.f);
	color = luaL_checkinteger(L, 7);
	
	float vertices[4][4] = {
		{0.f, 0.f,	0.f, 0.f},
		{0.f, 0.f,	0.f, 1.f},
		{0.f, 0.f,	1.f, 1.f},
		{0.f, 0.f,	1.f, 0.f},
	};

	for (int i = 1; i <= n; ++i) {
		lua_rawgeti(L, 1, i);
		ch = lua_touserdata(L, -1);

		posx = x + ch->offsetx;
		posy = y - (ch->height - ch->offsety);

		w = ch->width;
		h = ch->height;

		// 左上 -> 左下 -> 右下 -> 右上 (逆时针)
		ROTATE(x0, y0, angle, posx, posy+h, &vertices[0][0], &vertices[0][1]);
		ROTATE(x0, y0, angle, posx, posy,   &vertices[1][0], &vertices[1][1]);
		ROTATE(x0, y0, angle, posx+w, posy, &vertices[2][0], &vertices[2][1]);
		ROTATE(x0, y0, angle, posx+w, posy+h, &vertices[3][0], &vertices[3][1]);

		G->renderer->print(&vertices[0][0], ch->texture, color);
		
		lua_pop(L, 1);
		x = x + (ch->advancex >> 6);
	}

	return 0;
}


static int
ldraw(lua_State *L) {
	GLuint texture;
	float x, y, w, h, ax, ay, rotate, posx, posy;
	uint32_t color;
	float vertices[4][4];

	texture = luaL_checkinteger(L, 1);
	x = floor(luaL_checknumber(L,2));
	y = floor(luaL_checknumber(L,3));
	ax = luaL_checknumber(L, 4);
	ay = luaL_checknumber(L, 5);
	rotate = luaL_checknumber(L, 6) * M_PI/180.f;
	color = luaL_checkinteger(L, 7);
	w = luaL_checknumber(L, 8);
	h = luaL_checknumber(L, 9);

	vertices[0][2] = luaL_checknumber(L, 10);
	vertices[0][3] = luaL_checknumber(L, 11);
	vertices[1][2] = luaL_checknumber(L, 12);
	vertices[1][3] = luaL_checknumber(L, 13);
	vertices[2][2] = luaL_checknumber(L, 14);
	vertices[2][3] = luaL_checknumber(L, 15);
	vertices[3][2] = luaL_checknumber(L, 16);
	vertices[3][3] = luaL_checknumber(L, 17);

	// 左下角的世界坐标
	posx = x - ax * w;
	posy = y - ay * h;

	ROTATE(x, y, rotate, posx, posy+h,   &vertices[0][0], &vertices[0][1]);
	ROTATE(x, y, rotate, posx, posy,     &vertices[1][0], &vertices[1][1]);
	ROTATE(x, y, rotate, posx+w, posy,   &vertices[2][0], &vertices[2][1]);
	ROTATE(x, y, rotate, posx+w, posy+h, &vertices[3][0], &vertices[3][1]);

	G->renderer->draw(&vertices[0][0], texture, color);
    return 0;
}


static int
lclear(lua_State *L) {
	uint32_t c;
	c = luaL_checkinteger(L, 1);
	glClearColor(R(c), G(c), B(c), A(c));
	return 0;
}


static int
ltexture(lua_State *L) {
	GLuint texture;
	const char *filename;
	int width, height, channel;
	unsigned char *data;

	filename = luaL_checkstring(L, 1);
	data = stbi_load(filename, &width, &height, &channel, STBI_rgb_alpha);

	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	
	glBindTexture(GL_TEXTURE_2D, 0);
	stbi_image_free(data);

	lua_pushinteger(L, texture);
	lua_pushinteger(L, width);
	lua_pushinteger(L, height);
	return 3;
}

// 开始模板绘制 -> draw stencils(sprites) -> 结束模板绘制 -> draw sprites -> 清空模板
static int
lstart_stencil(lua_State *L) {
	glEnable(GL_STENCIL_TEST);
	glStencilFunc(GL_ALWAYS, 1, 0XFF);
	glStencilMask(0XFF);
	return 0;
}


static int
lstop_stencil(lua_State *L) {
	glStencilFunc(GL_EQUAL, 1, 0xFF);
	glStencilMask(0x00);
	return 0;
}


static int
lclear_stencil(lua_State *L) {
	glClear(GL_STENCIL_BUFFER_BIT);
	glDisable(GL_STENCIL_TEST);
	return 0;
}

int
lib_graphics(lua_State *L)
{
	stbi_set_flip_vertically_on_load(true);
	luaL_Reg l[] = {
		{"clear_stencil", lclear_stencil},
		{"stop_stencil", lstop_stencil},
		{"start_stencil", lstart_stencil},
		{"print", lprint},
		{"draw", ldraw},
		{"clear", lclear},
        {"texture", ltexture},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}