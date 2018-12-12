#ifndef WINDOW_H
#define WINDOW_H

#include "common.h"

typedef struct
{
	float width;
	float height;
	bool fullscreen;
	const char *title;
	GLFWwindow *handle;
	const GLFWvidmode *display;
	
	void (*destroy)(void);
} Window;



Window *
create_window();




#endif