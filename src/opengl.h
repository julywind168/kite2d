#ifndef OPENGL_H
#define OPENGL_H

#include "common.h"

#define CURRENT_CAMERA -1
#define SCREEN_CAMERA 0
#define WORLD_CAMERA 1

typedef struct
{
	GLuint cur_program;
	mat4x4 camera_mat[2];	// [0]:screen camera [1]:world camera

	GLuint sp_program;
	GLuint sp_color;
	GLuint sp_additive;
	GLuint sp_camera;
	uint8_t sp_cur_camera;

	GLuint tx_program;
	GLuint tx_color;
	GLuint tx_camera;
	uint8_t tx_cur_camera;


	FT_Library ft;
	GLuint ft_vao;
	GLuint ft_vbo;

	void (*update_camera)(float, float, float);
	void (*set_tx_color)(uint32_t);
	void (*set_sp_color)(uint32_t);
	void (*use_tx_program)(int);
	void (*use_sp_program)(int);
	void (*destroy)(void);
	void (*init)(void);
} Opengl;




Opengl *
create_opengl();



#endif