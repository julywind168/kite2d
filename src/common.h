#ifndef COMMON_H
#define COMMON_H

#define GLFW_INCLUDE_NONE

#include <glad/glad.h>
#include <glfw/glfw3.h>

#include <stdio.h>
#include <stdlib.h>

#include "util.h"


#define MAX(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _a : _b; })


#define MIN(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _b : _a; })


static inline void
ASSERT(int ok, const char * msg) {
	if (!ok) {
		fprintf(stderr, "%s\n", msg);
		exit(EXIT_FAILURE);
	}
}

#define R(color) (float)(color>>24) & 0xFF 
#define G(color) (float)(color>>16) & 0xFF 
#define B(color) (float)(color>>8) & 0xFF 
#define A(color) (float)(color) & 0xFF 

#endif
