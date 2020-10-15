#include "renderer.h"

#define VERT_SIZE 8
#define ITEM_SIZE sizeof(float)*4*VERT_SIZE
#define MAX_BATCH_SLOT 512


static struct renderer *renderer;


void
renderer_set_clearcolor(uint32_t c) {
	renderer->clearcolor_r = COLOR_R(c);
	renderer->clearcolor_g = COLOR_G(c);
	renderer->clearcolor_b = COLOR_B(c);
	renderer->clearcolor_a = COLOR_A(c);
}


void
renderer_use_program(uint32_t program) {
	if (program != renderer->cur_program) {
		glUseProgram(program);
		renderer->cur_program = program;
	}
}


void
renderer_bind_texture(uint32_t texture) {
	if (texture != renderer->cur_texture) {
		glBindTexture(GL_TEXTURE_2D, texture);
		renderer->cur_texture = texture;
	}
}


void
renderer_flush() {
	if (renderer->batch.count == 0) return;
	renderer_use_program(renderer->batch.program);
	renderer_bind_texture(renderer->batch.texture);
	glBufferSubData(GL_ARRAY_BUFFER, 0, ITEM_SIZE*renderer->batch.count, renderer->batch.vertices);
	glDrawElements(GL_TRIANGLES, 6 * renderer->batch.count, GL_UNSIGNED_INT, 0);
	renderer->batch.count = 0;
	renderer->drawc += 1;
}


void
renderer_draw_start() {
	glClearColor(renderer->clearcolor_r, renderer->clearcolor_g, renderer->clearcolor_b, renderer->clearcolor_a);
	glClear(GL_COLOR_BUFFER_BIT);
}


void
renderer_draw(struct sprite2d *sprite) {
	if ((sprite->texture != renderer->batch.texture) ||
		(sprite->program != renderer->batch.program) ||
		(renderer->batch.count == MAX_BATCH_SLOT)) {
		renderer_flush();
	}
	renderer->batch.program = sprite->program;
	renderer->batch.texture = sprite->texture;

	memcpy(renderer->batch.vertices + ITEM_SIZE/sizeof(float) * renderer->batch.count, sprite->p0, ITEM_SIZE);
	renderer->batch.count += 1;
}


uint32_t
renderer_draw_end() {
	uint32_t drawc;
	renderer_flush();
	drawc = renderer->drawc;
	renderer->drawc = 0;
	return drawc;
}


void
renderer_on_window_resize(uint32_t width, uint32_t height) {
	glViewport(0, 0, width, height);
}


int
renderer_init(uint32_t width, uint32_t height) {
	glViewport(0, 0, width, height);
	glEnable(GL_CULL_FACE);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// create draw resource
	uint32_t vao, vbo, ebo;
	uint32_t indices[6 * MAX_BATCH_SLOT];

	for (int i = 0; i < MAX_BATCH_SLOT; ++i)
	{
		indices[i*6 + 0] = 0 + i*4;
		indices[i*6 + 1] = 1 + i*4;
		indices[i*6 + 2] = 2 + i*4;
		indices[i*6 + 3] = 0 + i*4;
		indices[i*6 + 4] = 2 + i*4;
		indices[i*6 + 5] = 3 + i*4;
	}

	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, ITEM_SIZE* MAX_BATCH_SLOT, NULL, GL_DYNAMIC_DRAW);

	glGenBuffers(1, &ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

	// position (xy)
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, VERT_SIZE * sizeof(float), (void*)0);
    // color
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, VERT_SIZE * sizeof(float), (void*)(2 * sizeof(float)));
    // texture coord attribute
    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, VERT_SIZE * sizeof(float), (void*)(6 * sizeof(float)));

	renderer->vao = vao;
	renderer->vbo = vbo;
	renderer->ebo = ebo;
	return 0;
}


void
renderer_destroy() {
	if (renderer) {
		glDeleteVertexArrays(1, &renderer->vao);
		glDeleteBuffers(1, &renderer->vbo);
		glDeleteBuffers(1, &renderer->ebo);
		free(renderer);
	}
}


struct renderer *
create_renderer(uint32_t width, uint32_t height) {
	renderer = malloc(sizeof(struct renderer) +  ITEM_SIZE * MAX_BATCH_SLOT);

	if (renderer_init(width, height)) {
		free(renderer);
		return NULL;
	}

	renderer->batch.count = 0;
	renderer->batch.program = 0;
	renderer->batch.texture = 0;

	renderer->cur_program = 0;
	renderer->cur_texture = 0;
	renderer->drawc = 0;
	renderer->clearcolor_r = 0.f;
	renderer->clearcolor_g = 0.f;
	renderer->clearcolor_b = 0.f;
	renderer->clearcolor_a = 1.f;

	renderer->set_clearcolor = renderer_set_clearcolor;
	renderer->use_program = renderer_use_program;
	renderer->bind_texture = renderer_bind_texture;
	renderer->flush = renderer_flush;
	renderer->draw_start = renderer_draw_start;
	renderer->draw = renderer_draw;
	renderer->draw_end = renderer_draw_end;
	renderer->on_window_resize = renderer_on_window_resize;
	renderer->destroy = renderer_destroy;

	return renderer;
}