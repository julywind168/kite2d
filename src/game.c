#include "game.h"

Game *G;


void
game_run() {
	GLFWwindow *hwnd = G->window->handle;
	double now, dt;
	
	while(!glfwWindowShouldClose(hwnd)) {
		now = glfwGetTime();
		dt = now - G->time;
		G->time = now;
		G->kite->update(dt);

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		// glDisable(GL_STENCIL_TEST);
		
		G->kite->draw();
		G->renderer->commit();

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
	G->audio->destroy();
	free(G);
}


Game *
create_game(const char *gamedir) {
	G = malloc(sizeof(Game));

	G->drawcall = 0;
	G->time = 0.f;

	G->kite = create_kite(gamedir); 	if (G->kite == NULL)     {free(G); exit(EXIT_FAILURE);}
	G->window = create_window();		if (G->window == NULL)   {G->kite->destroy(); free(G); exit(EXIT_FAILURE);}
	G->renderer = create_renderer();	if (G->renderer == NULL) {G->kite->destroy(); G->window->destroy(); free(G); exit(EXIT_FAILURE);}
	G->audio = create_audio();			if (G->audio == NULL)    {G->kite->destroy(); G->window->destroy(); G->renderer->destroy(); free(G); exit(EXIT_FAILURE);}

	if (G->kite->load()) {
		G->kite->destroy();
		G->window->destroy();
		G->renderer->destroy();
		G->audio->destroy();
		free(G);
		exit(EXIT_FAILURE);
	}
	G->run = game_run;
	G->destroy = game_destroy;
	return G;
}