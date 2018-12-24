#ifndef RENDERER_H
#define RENDERER_H

#include "common.h"
#include "manager.h"


#define MAX_BATCH_SLOT 1024


typedef struct
{
	Manager *manager;
	
	FT_Library ft;
	GLuint vao;
	GLuint vbo;
	GLuint ebo;
	GLuint cur_texture;

	uint32_t drawc;

	void(*draw)(float *, GLuint, uint32_t);
	void(*print)(float *, GLuint, uint32_t);
	void(*commit)(void);
	void(*destroy)(void);

	uint32_t spritec;
	float vertices[];
} Renderer;



Renderer *
create_renderer();

#endif