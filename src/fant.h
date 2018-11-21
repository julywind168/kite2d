#ifndef FANT_H
#define FANT_H

#include "common.h"

typedef struct
{	
	float x;
	float y;
	float width;
	float height;
	bool fullscreen;
	char *title;
} __Window;


typedef struct
{
	float x;
	float y;
	float scale;
	float angle;
} __Camera;


typedef struct
{
	__Window window;
	__Camera camera;
} Conf;


typedef struct
{
	lua_State *L;
	Conf conf;

	//callback
	void (*init)(void);
	void (*update)(double);
	void (*draw)(void);
	void (*_cursor)(GLFWwindow*, double, double);
	void (*mouse)(GLFWwindow*, int, int, int);
	void (*keyboard)(GLFWwindow*, int, int, int, int);
	void (*destroy)(void);
} Fant;






Fant *
create_fant(const char *filename);



#endif