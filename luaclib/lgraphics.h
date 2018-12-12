#ifndef LGRAPHICS_H
#define LGRAPHICS_H

#include "common.h"


typedef struct
{
	GLuint id;
	int width;
	int height;
	float coord[8];
} Texture;


int
lib_graphics(lua_State *L);



#endif