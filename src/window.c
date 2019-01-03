#include "window.h"
#include "game.h"
#include "kite.h"

extern Game *G;
static Window *window;




static GLFWmonitor *
get_monitor() {
	int count = 0;
	GLFWmonitor **monitor =  glfwGetMonitors(&count);
	ASSERT(count > 0, "can't find display");
	return monitor[0];
}


static int
window_init() {

	GLFWmonitor *monitor;
	const GLFWvidmode *display;
	const char *title;
	float width, height;
	bool fullscreen;
	
	width = G->kite->conf.window.width;
	height = G->kite->conf.window.height;
	title = G->kite->conf.window.title;
	fullscreen = G->kite->conf.window.fullscreen;

	if (!glfwInit()) {
		fprintf(stderr, "failed to init glfw\n");
		return 1;
	}

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
		width = display->width;
		height = display->height;
		handle = glfwCreateWindow(width, height, title, monitor, NULL);
	} else {
		handle = glfwCreateWindow(width, height, title, NULL, NULL);
		glfwSetWindowPos(handle, display->width/2 - width/2, display->height/2 - height/2);
	}

	if (!handle) {
		fprintf(stderr, "failed to create window\n");
		return 1;
	}

	glfwSetKeyCallback(handle, G->kite->keyboard);
	glfwSetMouseButtonCallback(handle, G->kite->mouse);
	glfwSetCursorPosCallback(handle, G->kite->_cursor_move);
	glfwSetCursorEnterCallback(handle, G->kite->_cursor_enter);
	glfwSetCharCallback(handle, G->kite->message);
	glfwSetScrollCallback(handle, G->kite->scroll);

	window->width = width;
	window->height = height;
	window->title = title;
	window->fullscreen = fullscreen;
	window->handle = handle;
	window->display = display;
	return 0;
}


void
window_destroy() {
	glfwTerminate();
	free(window);
}

Window *
create_window() {
	window = malloc(sizeof(Window));
	window->destroy = window_destroy;

	if (window_init()) {
		free(window);
		return NULL;
	}

	return window;
}