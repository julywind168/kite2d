#include "game.h"
#include "opengl.h"
#include "util.h"

extern Game *G;
Opengl *opengl;



static void
on_window_resize(GLFWwindow *window, int width, int height) {
	glViewport(0, 0, width, height);
}




void
opengl_use_sp_program() {
	if (opengl->cur_program != opengl->sp_program) {
		glUseProgram(opengl->sp_program);
		opengl->cur_program = opengl->sp_program;
	}
}


void
opengl_use_tx_program() {
	if (opengl->cur_program != opengl->tx_program) {
		glUseProgram(opengl->tx_program);
		opengl->cur_program = opengl->tx_program;
	}
}


void
opengl_init() {
	// freetype
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

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);

	opengl->ft = ft;
	opengl->ft_vao = vao;
	opengl->ft_vbo = vbo;

	// programs
	mat4x4 camera;
	mat4x4_projection(camera, 0.f, G->window->width, 0.f, G->window->height);
	// text shader program
	GLuint tx_program;
	GLuint tx_shader_camera, tx_shader_color;
	tx_program = create_program("resource/text.vs", "resource/text.fs");
	glUseProgram(tx_program);
	glUniform1i(glGetUniformLocation(tx_program, "texture0"), 0);
	tx_shader_camera = glGetUniformLocation(tx_program, "camera");
	tx_shader_color = glGetUniformLocation(tx_program, "textcolor");

	glUniformMatrix4fv(tx_shader_camera, 1, GL_FALSE, &camera[0][0]);
	opengl->tx_program = tx_program;
	opengl->tx_shader_camera = tx_shader_camera;
	opengl->tx_shader_color = tx_shader_color;

	// sprite shader program
	GLuint sp_program;
	GLuint sp_shader_camera, sp_shader_color, sp_shader_additive;
	sp_program = create_program("resource/sprite.vs", "resource/sprite.fs");
	glUseProgram(sp_program);
	glUniform1i(glGetUniformLocation(sp_program, "texture0"), 0);
	sp_shader_camera = glGetUniformLocation(sp_program, "camera");
	sp_shader_color = glGetUniformLocation(sp_program, "color");
	sp_shader_additive = glGetUniformLocation(sp_program, "additive");
	
	glUniformMatrix4fv(sp_shader_camera, 1, GL_FALSE, &camera[0][0]);
	glUniform4f(sp_shader_color, 1.0f, 1.0f, 1.0f, 1.0f);
	glUniform4f(sp_shader_additive, 0.0f, 0.0f, 0.0f, 0.0f);
	opengl->sp_program = sp_program;
	opengl->sp_shader_camera = sp_shader_camera;
	opengl->sp_shader_color = sp_shader_color;
	opengl->sp_shader_additive = sp_shader_additive;

	// current program
	opengl->cur_program = sp_program;
}


void
opengl_destroy() {
	FT_Done_FreeType(opengl->ft);
	free(opengl);
}


Opengl *
create_opengl() {
	glfwMakeContextCurrent(G->window->handle);
	ASSERT(gladLoadGLLoader((GLADloadproc)glfwGetProcAddress), "failed to init glad!");
	glViewport(0, 0, G->window->width, G->window->height);
	glfwSetFramebufferSizeCallback(G->window->handle, on_window_resize);
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

	opengl = malloc(sizeof(Opengl));
	opengl->init = opengl_init;
	opengl->destroy = opengl_destroy;
	opengl->use_sp_program = opengl_use_sp_program;
	opengl->use_tx_program = opengl_use_tx_program;
	return opengl;
}