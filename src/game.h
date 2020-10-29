#ifndef GAME_H
#define GAME_H

#include "common.h"
#include "renderer.h"
#include "audio.h"


#define KITE_UPDATE 1
#define KITE_DRAW 2
#define KITE_MOUSE 3
#define KITE_KEYBOARD 4
#define KITE_TEXTINPUT 5
#define KITE_PAUSE 6
#define KITE_RESUME 7
#define KITE_SCROLL 8
#define KITE_RESIZE 9
#define KITE_EXIT 10

#define MOUSE_PRESS 1
#define MOUSE_RELEASE 2
#define MOUSE_MOVE 3
#define MOUSE_ENTER 4
#define MOUSE_LEAVE 5

#define MOUSE_LEFT 1
#define MOUSE_RIGHT 2

#define KEY_PRESS 1
#define KEY_RELEASE 2


struct window
{	
	uint32_t width;
	uint32_t height;
	bool fullscreen;
	const char *icon;
	const char *title;
};


struct conf
{
	struct window window;
};


struct game
{
	struct conf conf;
	lua_State *L;
	uint32_t width;
	uint32_t height;
	uint32_t drawcall;

	const char *environment;	// "simulator", "device", "browser"
	const char *platform;		// "windows", "android", "ios", "macos", "html5"
	char *gamedir;


	struct renderer *renderer;
	struct audio *audio;

#ifdef __DESKTOP__
	GLFWwindow *hwnd;
#endif

	void (*on_resize)(int, int);
	void (*on_resume)(void);
	void (*on_pause)(void);
	void (*on_scroll)(double, double);
	void (*on_textinput)(uint32_t);
	void (*on_keyboard)(int, int);
	void (*on_mouse)(int, int, int, int);
	void (*exit)(void);
	void (*draw)(float);
	void (*destroy)(void);
	bool (*init)(uint32_t, uint32_t);
};



struct game *
create_game(const char *gamedir, const char *environment, const char *platform);



#endif