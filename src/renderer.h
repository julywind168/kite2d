#ifndef RENDERER_H
#define RENDERER_H

#include "common.h"
#include "manager.h"


#define MAX_BATCH_SLOT 1024



typedef struct
{
	int program;
	uint32_t color;
	GLuint texture;

	uint32_t count;
	float vertices[];	
} Batch;


typedef struct
{
	Manager *manager;
	
	FT_Library ft;
	GLuint vao;
	GLuint vbo;
	GLuint ebo;
	
	uint32_t drawc;

	GLuint cur_texture;
	void(*bind_texture)(GLuint);
	void(*draw)(float *, GLuint, uint32_t, int);
	void(*flush)(void);
	void(*commit)(void);
	void(*destroy)(void);

	Batch batch;
} Renderer;



Renderer *
create_renderer();

#endif