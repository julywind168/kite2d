#include "lfont.h"
#include "game.h"

extern Game *G;


static int
lchar(lua_State *L) {
	FT_Face face;
    GLuint texture, id;

    face = lua_touserdata(L, 1);
    id = luaL_checkinteger(L, 2);
    if (FT_Load_Char(face, id, FT_LOAD_RENDER)) {
        return luaL_error(L, "failed to load char: %d\n", id);
    }
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(
        GL_TEXTURE_2D,
        0,
        GL_RED,
        face->glyph->bitmap.width,
        face->glyph->bitmap.rows,
        0,
        GL_RED,
        GL_UNSIGNED_BYTE,
        face->glyph->bitmap.buffer
    );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D, 0);

    Character *ch = lua_newuserdata(L, sizeof(Character));
    ch->texture = texture;
    ch->width = face->glyph->bitmap.width;
    ch->height = face->glyph->bitmap.rows;
    ch->offsetx = face->glyph->bitmap_left;
    ch->offsety = face->glyph->bitmap_top;
    ch->advancex = face->glyph->advance.x;
	return 1;
}


static int
lface(lua_State *L) {
	FT_Library ft = G->opengl->ft;
	FT_Face face;
	const char *filename;
	int size;

	filename = luaL_checkstring(L, 1);
	size = luaL_optinteger(L, 2, 48);

	if (FT_New_Face(ft, filename, 0, &face)) {
		return luaL_error(L, "failed to load font:%s", filename);
	}
	FT_Set_Pixel_Sizes(face, 0, size);
	lua_pushlightuserdata(L, face);
	return 1;
}


int
lib_font(lua_State *L)
{
	luaL_Reg l[] = {
        {"char", lchar},
        {"face", lface},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}