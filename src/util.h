#ifndef UTIL_H
#define UTIL_H

#include "common.h"



unsigned char *
load_image(const char *, int *, int *, int *, bool);


#define destroy_image stbi_image_free



#endif