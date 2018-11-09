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
	int width;
	int height;
	double time;
	GLFWwindow *window;
	GLuint program;
	GLuint transform;

	lua_State *L;
} Game;



void
game_start(Game *);


void
destroy_game(Game *);


Game *
create_game(const char *filename);







#endif