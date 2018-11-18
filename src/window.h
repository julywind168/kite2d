#ifndef WINDOW_H
#define WINDOW_H

#include "common.h"

typedef struct
{
	float x;
	float y;
	float width;
	float height;
	bool fullscreen;
	const char *title;
	GLFWwindow *handle;
	const GLFWvidmode *display;

	void (*init)(void);
	void (*destroy)(void);
} Window;



Window *
create_window();




#endif