#ifndef PROGRAM_H
#define PROGRAM_H

#include "common.h"


#define PROGRAM_SPRITE 1
#define PROGRAM_TEXT 2

typedef struct
{
	GLuint id;
	GLuint color;
	GLuint projection;
	uint32_t cur_color;
} Program;


typedef struct
{
	Program sprite;
	Program text;
	uint8_t current;

	bool(*use_sprite_program)(uint32_t color, bool test);
	bool(*use_text_program)(uint32_t color, bool test);
	void(*destroy)(void);
} Manager;



Manager *
create_manager();


#endif