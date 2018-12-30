#ifndef LFONT_H
#define LFONT_H

#include "common.h"



typedef struct
{
    GLuint texture;
    float width;
    float height;
    float offsetx;
    float offsety;
    GLuint advancex;
} Character;


int
lib_font(lua_State *L);



#endif