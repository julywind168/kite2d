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
opengl_use_sp_program(int camera) {
	if (opengl->cur_program != opengl->sp_program) {
		glUseProgram(opengl->sp_program);
		opengl->cur_program = opengl->sp_program;
	}
	if (camera != CURRENT_CAMERA && opengl->sp_cur_camera != camera) {
		glUniformMatrix4fv(opengl->sp_camera, 1, GL_FALSE, &opengl->camera_mat[camera][0][0]);
		opengl->sp_cur_camera = camera;
	}
}


void
opengl_use_tx_program(int camera) {
	if (opengl->cur_program != opengl->tx_program) {
		glUseProgram(opengl->tx_program);
		opengl->cur_program = opengl->tx_program;
	}
	if (camera != CURRENT_CAMERA && opengl->tx_cur_camera != camera) {
		glUniformMatrix4fv(opengl->tx_camera, 1, GL_FALSE, &opengl->camera_mat[camera][0][0]);
		opengl->tx_cur_camera = camera;
	}
}

void
opengl_set_sp_color(uint32_t c) {
	opengl_use_sp_program(CURRENT_CAMERA);
	glUniform4f(opengl->sp_color, R(c), G(c), B(c), A(c));
}

void
opengl_set_tx_color(uint32_t c) {
	opengl_use_tx_program(CURRENT_CAMERA);
	glUniform4f(opengl->tx_color, R(c), G(c), B(c), A(c));
}


void
opengl_update_camera(float x, float y, float scale) {
	float width = G->window->width * scale;
	float height = G->window->height * scale;
	float offset_x = x - width/2;
	float offset_y = y - height/2;

	mat4x4_ortho(opengl->camera_mat[WORLD_CAMERA], offset_x, width + offset_x,
		offset_y, height + offset_y, -1, 1);

	opengl_use_sp_program(CURRENT_CAMERA);
	glUniformMatrix4fv(opengl->sp_camera, 1, GL_FALSE, &opengl->camera_mat[WORLD_CAMERA][0][0]);

	opengl_use_tx_program(CURRENT_CAMERA);
	glUniformMatrix4fv(opengl->tx_camera, 1, GL_FALSE, &opengl->camera_mat[WORLD_CAMERA][0][0]);
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

	// cameras
	mat4x4_ortho(opengl->camera_mat[SCREEN_CAMERA], 0.f, G->window->width, 0.f, G->window->height, -1.f, 1.f);

	float width = G->window->width * G->fant->conf.camera.scale;
	float height = G->window->height * G->fant->conf.camera.scale;
	float offset_x = G->fant->conf.camera.x - width/2;
	float offset_y = G->fant->conf.camera.y - height/2;

	mat4x4_ortho(opengl->camera_mat[WORLD_CAMERA], offset_x, width + offset_x,
		offset_y, height + offset_y, -1, 1);

	// text shader program
	GLuint tx_program;
	GLuint tx_camera, tx_color;

	tx_program = create_program("resource/text.vs", "resource/text.fs");
	glUseProgram(tx_program);
	glUniform1i(glGetUniformLocation(tx_program, "texture0"), 0);

	tx_camera = glGetUniformLocation(tx_program, "camera");
	tx_color = glGetUniformLocation(tx_program, "textcolor");

	glUniformMatrix4fv(tx_camera, 1, GL_FALSE, &opengl->camera_mat[SCREEN_CAMERA][0][0]);
	opengl->tx_program = tx_program;
	opengl->tx_color = tx_color;
	opengl->tx_camera = tx_camera;

	// sprite shader program
	GLuint sp_program;
	GLuint sp_camera, sp_color, sp_additive;
	sp_program = create_program("resource/sprite.vs", "resource/sprite.fs");
	glUseProgram(sp_program);
	glUniform1i(glGetUniformLocation(sp_program, "texture0"), 0);

	sp_camera = glGetUniformLocation(sp_program, "camera");
	sp_color = glGetUniformLocation(sp_program, "color");
	sp_additive = glGetUniformLocation(sp_program, "additive");
	glUniformMatrix4fv(sp_camera, 1, GL_FALSE, &opengl->camera_mat[SCREEN_CAMERA][0][0]);
	
	glUniform4f(sp_color, 1.0f, 1.0f, 1.0f, 1.0f);
	glUniform4f(sp_additive, 0.0f, 0.0f, 0.0f, 0.0f);
	opengl->sp_program = sp_program;
	opengl->sp_camera = sp_camera;
	opengl->sp_color = sp_color;
	opengl->sp_additive = sp_additive;

	// current status
	opengl->cur_program = sp_program;
	opengl->tx_cur_camera = SCREEN_CAMERA;
	opengl->sp_cur_camera = SCREEN_CAMERA;
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
	
	opengl->set_sp_color = opengl_set_sp_color;
	opengl->set_tx_color = opengl_set_tx_color;

	opengl->update_camera = opengl_update_camera;
	return opengl;
}