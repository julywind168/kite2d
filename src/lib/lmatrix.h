#ifndef LMATRIX_H
#define LMATRIX_H

#include "common.h"


struct mat4x4
{
	float m0[4];
	float m1[4];
	float m2[4];
	float m3[4];
};



int
lib_matrix(lua_State *L);




#endif