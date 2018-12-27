#include "manager.h"
#include "util.h"
#include "game.h"

extern Game *G;
static Manager *manager;


void
manager_use_sprite_program(uint32_t color) {
	if (manager->current != PROGRAM_SPRITE) {
		glUseProgram(manager->sprite.id);
		manager->current = PROGRAM_SPRITE;
	}
	if (color != manager->sprite.cur_color) {
		glUniform4f(manager->sprite.color, R(color), G(color), B(color), A(color));
		manager->sprite.cur_color = color;
	}
}


void
manager_use_text_program(uint32_t color) {
	if (manager->current != PROGRAM_TEXT) {
		glUseProgram(manager->text.id);
		manager->current = PROGRAM_TEXT;
		glUniform4f(manager->text.color, R(color), G(color), B(color), A(color));
		manager->text.cur_color = color;
	}
	if (color != manager->text.cur_color) {
		glUniform4f(manager->text.color, R(color), G(color), B(color), A(color));
		manager->text.cur_color = color;
	}
}


void
manager_destroy() {
	glDeleteProgram(manager->sprite.id);
	glDeleteProgram(manager->text.id);
	free(manager);
}


Manager *
create_manager() {
	manager = malloc(sizeof(Manager));

	mat4x4 projection;
	mat4x4_ortho(projection, 0.f, G->window->width, 0.f, G->window->height, -1.f, 1.f);

	// init text manager
	manager->text.id = program_from_file("resource/text.vs", "resource/text.fs");
	glUseProgram(manager->text.id);
	manager->text.projection = glGetUniformLocation(manager->text.id, "projection");
	manager->text.color = glGetUniformLocation(manager->text.id, "color");
	manager->text.cur_color = 0xffffffff;

	glUniform1i(glGetUniformLocation(manager->text.id, "texture0"), 0);
	glUniformMatrix4fv(manager->text.projection, 1, GL_FALSE, &projection[0][0]);
	glUniform4f(manager->text.color, 1.0f, 1.0f, 1.0f, 1.0f);

	// init sprite program
	manager->sprite.id = program_from_file("resource/sprite.vs", "resource/sprite.fs");
	glUseProgram(manager->sprite.id);
	manager->sprite.projection = glGetUniformLocation(manager->sprite.id, "projection");
	manager->sprite.color = glGetUniformLocation(manager->sprite.id, "color");
	manager->sprite.cur_color = 0xffffffff;

	glUniform1i(glGetUniformLocation(manager->sprite.id, "texture0"), 0);
	glUniformMatrix4fv(manager->sprite.projection, 1, GL_FALSE, &projection[0][0]);
	glUniform4f(manager->sprite.color, 1.0f, 1.0f, 1.0f, 1.0f);

	manager->use_text_program = manager_use_text_program;
	manager->use_sprite_program = manager_use_sprite_program;
	manager->current = PROGRAM_SPRITE;
	manager->destroy = manager_destroy;
	return manager;
}