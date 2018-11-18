#include "game.h"
#include "window.h"
#include "fant.h"

Game *G;


void
game_run() {
	GLFWwindow *hwnd = G->window->handle;
	double now,dt;
	
	while(!glfwWindowShouldClose(hwnd)) {
		now = glfwGetTime();
		dt = now - G->time;
		G->time = now;
		G->fant->update(dt);
		glClear(GL_COLOR_BUFFER_BIT);
		glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		G->fant->draw();

		glfwPollEvents();
		glfwSwapBuffers(hwnd);
	}
}


void
game_init() {
	G->time = glfwGetTime();
	G->window->init();
	G->opengl->init();
	G->fant->init();
}


void
game_destroy() {
	G->window->destroy();
	G->fant->destroy();
	G->opengl->destroy();
	free(G);
}


Game *
create_game(const char *filename) {
	G = malloc(sizeof(Game));
	G->fant = create_fant(filename); if (G->fant == NULL) {free(G); exit(EXIT_FAILURE);}
	G->window = create_window();
	G->opengl = create_opengl();

	G->init = game_init;
	G->run = game_run;
	G->destroy = game_destroy;
	return G;
}