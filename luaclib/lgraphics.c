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
	x0 = luaL_checknumber(L, 2);
	y0 = luaL_checknumber(L, 3);
	x = luaL_checknumber(L, 4);
	y = luaL_checknumber(L, 5);
	angle = luaL_checknumber(L, 6) * (M_PI/180.f);
	color = luaL_checkinteger(L, 7);
	
	float vertices[4][4] = {
		{0.f, 0.f,	0.f, 0.f},
		{0.f, 0.f,	0.f, 1.f},
		{0.f, 0.f,	1.f, 1.f},
		{0.f, 0.f,	1.f, 0.f},
	};

	G->renderer->manager->use_text_program(color);

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

		G->renderer->draw(&vertices[0][0], ch->texture);
		
		lua_pop(L, 1);
		x = x + (ch->advancex >> 6);
	}

	return 0;
}


static int
ldraw(lua_State *L) {
	Texture *tex;
	float x, y, posx, posy, w, h;
	float ax, ay, sx, sy, rotate;
	uint32_t color;
	float vertices[4][4];

	tex = lua_touserdata(L, 1);
	x = luaL_checknumber(L, 2);
	y = luaL_checknumber(L, 3);
	ax = luaL_checknumber(L, 4);
	ay = luaL_checknumber(L, 5);
	sx = luaL_checknumber(L, 6);
	sy = luaL_checknumber(L, 7);
	rotate = luaL_checknumber(L, 8) * M_PI/180.f;
	color = luaL_checkinteger(L, 9);
	w = luaL_optnumber(L, 10, tex->width) * sx;
	h = luaL_optnumber(L, 11, tex->height) * sy;

	// 左下角的世界坐标
	posx = x - ax * w;
	posy = y - ay * h;

	ROTATE(x, y, rotate, posx, posy+h,   &vertices[0][0], &vertices[0][1]);
	ROTATE(x, y, rotate, posx, posy,     &vertices[1][0], &vertices[1][1]);
	ROTATE(x, y, rotate, posx+w, posy,   &vertices[2][0], &vertices[2][1]);
	ROTATE(x, y, rotate, posx+w, posy+h, &vertices[3][0], &vertices[3][1]);

	vertices[0][2] = tex->coord[0]; vertices[0][3] = tex->coord[1];
	vertices[1][2] = tex->coord[2]; vertices[1][3] = tex->coord[3];
	vertices[2][2] = tex->coord[4]; vertices[2][3] = tex->coord[5];
	vertices[3][2] = tex->coord[6]; vertices[3][3] = tex->coord[7];

	G->renderer->manager->use_sprite_program(color);
	G->renderer->draw(&vertices[0][0], tex->id);
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
ltexture_size(lua_State *L) {
	Texture *tex;
	tex = lua_touserdata(L, 1);
	lua_pushinteger(L, tex->width);
	lua_pushinteger(L, tex->height);
	return 2;
}


static int
ltexture(lua_State *L) {
	GLuint texture;
	const char *filename;
	int width, height, channel;
	unsigned char *data;
	Texture* tex;
	float default_coord[8] = {0.f, 1.f, 0.f, 0.f, 1.f, 0.f, 1.f, 1.f};

	filename = luaL_checkstring(L, 1);
	data = stbi_load(filename, &width, &height, &channel, STBI_rgb_alpha);

	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	
	glBindTexture(GL_TEXTURE_2D, 0);
	stbi_image_free(data);

	tex = lua_newuserdata(L, sizeof(Texture));
	tex->id = texture;
	tex->width = width;
	tex->height = height;

	if (lua_istable(L, 2)) {
		for (int i = 0; i < 8; ++i) {
			lua_rawgeti(L, 2, i+1);
			tex->coord[i] = lua_tonumber(L, -1);
		}
		lua_pushvalue(L, 3);
	} else {
		memcpy(tex->coord, default_coord, sizeof(float)*8);
	}
	return 1;
}


int
lib_graphics(lua_State *L)
{
	stbi_set_flip_vertically_on_load(true);
	luaL_Reg l[] = {
		{"print", lprint},
		{"draw", ldraw},
		{"clear", lclear},
        {"texture", ltexture},
        {"texture_size", ltexture_size},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}