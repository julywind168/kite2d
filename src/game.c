#include "game.h"

Game *G;


void
game_run() {
	GLFWwindow *hwnd = G->window->handle;
	double now, dt;

	G->kite->start();
	
	while(!glfwWindowShouldClose(hwnd)) {
		now = glfwGetTime();
		dt = now - G->time;
		G->time = now;
		G->kite->update(dt);

		glClear(GL_COLOR_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
		glDisable(GL_STENCIL_TEST);
		G->kite->draw();

		glfwPollEvents();
		glfwSwapBuffers(hwnd);
	}
	G->kite->exit();
}


void
game_destroy() {
	G->kite->destroy();
	G->renderer->destroy();
	G->window->destroy();
	free(G);
}


Game *
create_game(const char *gamedir) {
	G = malloc(sizeof(Game));

	G->kite = create_kite(gamedir); 	if (G->kite == NULL) {free(G); exit(EXIT_FAILURE);}
	G->window = create_window();		if (G->window == NULL) {free(G); exit(EXIT_FAILURE);}
	G->renderer = create_renderer();	if (G->renderer == NULL) {free(G); exit(EXIT_FAILURE);}

	if (G->kite->load()) {
		G->kite->destroy();
		G->window->destroy();
		free(G);
		exit(EXIT_FAILURE);
	}
	G->run = game_run;
	G->destroy = game_destroy;
	return G;
}