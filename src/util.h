#ifndef UTIL_H
#define UTIL_H

#include "common.h"



GLuint
loadbmp(const char * imagepath);


GLuint
create_program();


char*
readfile(const char* name, int* sz);




#endif