#ifndef GAME_H
#define GAME_H

#include "fant.h"
#include "window.h"
#include "opengl.h"

typedef struct
{
	Window *window;			// 窗口管理
	Opengl *opengl;			// opengl管理
	Fant *fant;				// lua逻辑管理
	double time;			// 累计游戏时间

	void (*init)(void);
	void (*run)(void);
	void (*destroy)(void);
} Game;




Game *
create_game(const char *);



#endif