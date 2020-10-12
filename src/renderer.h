#ifndef RENDERER_H
#define RENDERER_H

#include "common.h"
#include "lsprite2d.h"



struct batch
{
	uint32_t program;
	uint32_t texture;
	uint32_t count;
	float vertices[];	
};


struct renderer
{	
	uint32_t vao;
	uint32_t vbo;
	uint32_t ebo;
	
	uint32_t drawc;
	float clearcolor_r;
	float clearcolor_g;
	float clearcolor_b;
	float clearcolor_a;

	uint32_t cur_program;
	uint32_t cur_texture;

	void (*set_clearcolor)(uint32_t);
	void (*use_program)(uint32_t);
	void (*bind_texture)(uint32_t);
	void (*flush)(void);
	void (*draw_start)(void);
	void (*draw)(struct sprite2d *);
	uint32_t (*draw_end)(void);
	void (*on_window_resize)(uint32_t, uint32_t);
	void (*destroy)(void);

	struct batch batch;
};


struct renderer *
create_renderer(uint32_t width, uint32_t height);



#endif