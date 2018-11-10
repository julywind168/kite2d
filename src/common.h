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

#define R(c) ((c>>24)&0xFF)/255
#define G(c) ((c>>16)&0xFF)/255
#define B(c) ((c>>8) &0xFF)/255
#define A(c) (c      &0xFF)/255

#endif
