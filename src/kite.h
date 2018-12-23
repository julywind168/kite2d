#ifndef KITE_H
#define KITE_H

#include "common.h"

typedef struct
{	
	float width;
	float height;
	bool fullscreen;
	char *title;
} __Window;


typedef struct
{
	const char *gamedir;
	__Window window;
} Conf;


typedef struct
{
	lua_State *L;
	Conf conf;
	
	//callback
	int (*load)(void);
	void (*update)(double);
	void (*draw)(void);
	void (*_cursor_enter)(GLFWwindow*, int);
	void (*_cursor_move)(GLFWwindow*, double, double);
	void (*mouse)(GLFWwindow*, int, int, int);
	void (*keyboard)(GLFWwindow*, int, int, int, int);
	void (*message)(GLFWwindow*, uint32_t);
	void (*exit)(void);

	void (*destroy)(void);
} Kite;






Kite *
create_kite(const char *);



#endif