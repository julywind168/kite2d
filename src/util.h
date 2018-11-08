#ifndef UTIL_H
#define UTIL_H

#include <stdio.h>
#include <stdlib.h>
#include <glad/glad.h>
#include <GLFW/glfw3.h>


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


GLuint
loadbmp(const char * imagepath);


GLuint
create_program();


char*
readfile(const char* name, int* sz);




#endif