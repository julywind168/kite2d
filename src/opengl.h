#ifndef OPENGL_H
#define OPENGL_H


typedef struct
{
	GLuint cur_program;

	GLuint sp_program;
	GLuint sp_shader_camera;
	GLuint sp_shader_color;
	GLuint sp_shader_additive;

	GLuint tx_program;
	GLuint tx_shader_camera;
	GLuint tx_shader_color;

	FT_Library ft;
	GLuint ft_vao;
	GLuint ft_vbo;

	void (*use_tx_program)(void);
	void (*use_sp_program)(void);
	void (*destroy)(void);
	void (*init)(void);
} Opengl;




Opengl *
create_opengl();



#endif