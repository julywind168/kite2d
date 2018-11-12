#ifndef GAME_H
#define GAME_H

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>

#include "common.h"
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"


typedef struct
{
	int win_x;
	int win_y;
	uint32_t win_width;
	uint32_t win_height;
	GLFWwindow *win_handle;
	GLFWmonitor *monitor;
	const GLFWvidmode *display;

	GLuint program;
	GLuint camera;
	GLuint window;
	
	uint32_t camera_x;
	uint32_t camera_y;

	double time;
	lua_State *L;
} Game;



void
game_start(Game *);


void
destroy_game(Game *);


Game *
create_game(const char *filename);







#endif