#include "game.h"
#include "renderer.h"

extern Game *G;
static Renderer *renderer;


void
renderer_draw(float *vertices, GLuint texture) {
	if (texture != renderer->cur_texture) {
		glBindTexture(GL_TEXTURE_2D, texture);
		renderer->cur_texture = texture;
	}
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(float)*4*4, vertices);
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}


static void
on_window_resize(GLFWwindow *window, int width, int height) {
	glViewport(0, 0, width, height);
}


static int
renderer_init() {

	// init opengl
	glfwMakeContextCurrent(G->window->handle);
	if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
		fprintf(stderr, "failed to init glad!\n");
		return 1;
	}
	glViewport(0, 0, G->window->width, G->window->height);
	glfwSetFramebufferSizeCallback(G->window->handle, on_window_resize);
	glEnable(GL_CULL_FACE);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_STENCIL_TEST);
	glStencilFunc(GL_NOTEQUAL, 1, 0xFF);
	glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

	// create draw resource
	FT_Library ft;
	GLuint vao, vbo, ebo;
	FT_Init_FreeType(&ft);
	static GLuint indices[] = {
		0,1,2,
		0,2,3
    };

	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);

	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	glBufferData(GL_ARRAY_BUFFER, sizeof(float)*4*4, NULL, GL_DYNAMIC_DRAW);

	glGenBuffers(1, &ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

	glEnableVertexAttribArray(0);
	glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4*sizeof(float), 0);

	renderer->ft = ft;
	renderer->vao = vao;
	renderer->vbo = vbo;
	renderer->ebo = ebo;
	renderer->cur_texture = 0;
	return 0;
}


void
renderer_destroy() {
	renderer->manager->destroy();
	FT_Done_FreeType(renderer->ft);
	glDeleteVertexArrays(1, &renderer->vao);
	glDeleteBuffers(1, &renderer->vbo);
	glDeleteBuffers(1, &renderer->ebo);
	free(renderer);
}


Renderer *
create_renderer() {
	renderer = malloc(sizeof(Renderer));

	if (renderer_init()) {
		free(renderer);
		return NULL;
	}

	renderer->manager = create_manager();

	if (renderer->manager == NULL) {
		FT_Done_FreeType(renderer->ft);
		glDeleteVertexArrays(1, &renderer->vao);
		glDeleteBuffers(1, &renderer->vbo);
		glDeleteBuffers(1, &renderer->ebo);
		free(renderer);
		return NULL;
	}

	renderer->draw = renderer_draw;
	renderer->destroy = renderer_destroy;
	return renderer;
}