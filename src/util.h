#ifndef UTIL_H
#define UTIL_H

#include "common.h"


void
mat4x4_projection(mat4x4 M, float left, float right, float bottom, float top);


GLuint
create_program(const char* vs_name, const char* fs_name);



#endif