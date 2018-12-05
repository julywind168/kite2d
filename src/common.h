#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#include <ft2build.h>
#include FT_FREETYPE_H  
#define GLFW_INCLUDE_NONE
#include <glad/glad.h>
#include <glfw/glfw3.h>
#include <linmath.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>


#define R(c) ((c>>24)&0xFF)/255.0f
#define G(c) ((c>>16)&0xFF)/255.0f
#define B(c) ((c>>8) &0xFF)/255.0f
#define A(c) (c      &0xFF)/255.0f


#define FF_ERROR(f_, ...) printf((f_), ##__VA_ARGS__); exit(EXIT_FAILURE)


static inline void
ASSERT(int ok, const char * msg) {
	if (!ok) {
		fprintf(stderr, "%s\n", msg);
		exit(EXIT_FAILURE);
	}
}







#endif