#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <assert.h>
#include <pthread.h>
#include <stdatomic.h>

#include <stb_image.h>

#include <AL/al.h>
#include <AL/alc.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>


#ifdef __ANDROID__
	#include <GLES3/gl3.h>
	#include <GLES3/gl3ext.h>
	#include <android/log.h>
	#define LOG(...) ((void)__android_log_print(ANDROID_LOG_WARN, "kite", __VA_ARGS__))
#else
	#define GLFW_INCLUDE_NONE
	#include <glad/glad.h>
	#include <glfw/glfw3.h>
	#define LOG(...) fprintf(stderr, __VA_ARGS__); fflush(stderr)
#endif


#define FREE(p); if(p) {free(p); p = NULL;}

#define COLOR_R(c) ((c>>24)&0xFF)/255.0f
#define COLOR_G(c) ((c>>16)&0xFF)/255.0f
#define COLOR_B(c) ((c>>8) &0xFF)/255.0f
#define COLOR_A(c) (c      &0xFF)/255.0f




#endif