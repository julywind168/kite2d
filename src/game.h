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
	uint32_t width;
	uint32_t height;
	double time;
	GLFWwindow *window;
	GLuint program;
	GLuint display;
	GLuint camera;

	lua_State *L;
} Game;



void
game_start(Game *);


void
destroy_game(Game *);


Game *
create_game(const char *filename);







#endif