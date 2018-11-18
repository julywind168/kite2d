#include "window.h"
#include "game.h"
#include "fant.h"

extern Game *G;
Window *window;

void
window_destroy() {
	glfwTerminate();
	free(window);
}


GLFWmonitor *
get_monitor() {
	int count = 0;
	GLFWmonitor **monitor =  glfwGetMonitors(&count);
	ASSERT(count > 0, "can't find display");
	return monitor[0];
}


void
window_init() {
	glfwSetKeyCallback(window->handle, G->fant->keyboard);
	glfwSetMouseButtonCallback(window->handle, G->fant->mouse);
	glfwSetCursorPosCallback(window->handle, G->fant->_cursor);
}


Window *
create_window() {

	GLFWmonitor *monitor;
	const GLFWvidmode *display;
	const char *title;
	float x, y, width, height;
	bool fullscreen;

	x = G->fant->conf.window.x;
	y = G->fant->conf.window.y;
	width = G->fant->conf.window.width;
	height = G->fant->conf.window.height;
	title = G->fant->conf.window.title;
	fullscreen = G->fant->conf.window.fullscreen;

	ASSERT(glfwInit(), "failed to init glfw");
	glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

	monitor = get_monitor();
	display = glfwGetVideoMode(monitor);
	glfwWindowHint(GLFW_RED_BITS, display->redBits);
	glfwWindowHint(GLFW_GREEN_BITS, display->greenBits);
	glfwWindowHint(GLFW_BLUE_BITS, display->blueBits);
	glfwWindowHint(GLFW_REFRESH_RATE, display->refreshRate);

	GLFWwindow *handle;
	if (fullscreen) {
		x = display->width/2;
		y = display->height/2;
		width = display->width;
		height = display->height;
		handle = glfwCreateWindow(width, height, title, monitor, NULL);
	} else {
		handle = glfwCreateWindow(width, height, title, NULL, NULL);
		glfwSetWindowPos(handle, x - width/2, display->height - y - height/2);
	}
	ASSERT((int64_t)handle, "failed to create window");

	window = malloc(sizeof(Window) + strlen(title) + 1);
	window->x = x;
	window->y = y;
	window->width = width;
	window->height = height;
	window->handle = handle;
	window->title = title;

	window->init = window_init;
	window->destroy = window_destroy;
	return window;
}

/*
	px = x0 - w/2
	py = display.h-h/2-y0
*/