#include "util.h"
#include "common.h"


int filesize(FILE*stream)
{
	int curpos, length;
	
	curpos = ftell(stream);
	fseek(stream, 0L, SEEK_END);
	
	length = ftell(stream);
	fseek(stream, curpos, SEEK_SET);
	return length;
}

char * readfile(const char* name, int *sz) {
	FILE *fp = fopen(name, "rb");
	if (!fp) {
		fprintf(stderr, "failed to open file: %s\n", name);
		exit(1);
	}

	int size = filesize(fp);
	char *data = malloc(size);

	fread(data, size, 1, fp);

	if (sz) {
		*sz = size;
	}

	fclose(fp);

	return data;
}


GLuint create_shader(const char* file, GLenum type) {
	GLuint shader = glCreateShader(type);
	ASSERT(shader != 0, "failed to create shader\n");

	GLint sz;
	const char * text = readfile(file, &sz);
	glShaderSource(shader, 1, &text, &sz);
	glCompileShader(shader);

	GLint success;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
	if (!success) {
    	GLchar info[1024];
        glGetShaderInfoLog(shader, 1024, NULL, info);
        fprintf(stderr, "faield to compile shader[%s] type:%d, '%s'\n", file, type, info);
        exit(1);
	}
	return shader;
}

GLuint
create_program(const char *vs_name, const char *fs_name) {
	GLuint vs = create_shader(vs_name, GL_VERTEX_SHADER);
	GLuint fs = create_shader(fs_name, GL_FRAGMENT_SHADER);
	GLuint program = glCreateProgram();
	glAttachShader(program, fs);
	glAttachShader(program, vs);
	glLinkProgram(program);

    GLint success = 0;
    GLchar err_info[1024] = { 0 };
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(program, sizeof(err_info), NULL, err_info);
        fprintf(stderr, "failed to link shader program: '%s'\n", err_info);
        exit(1);
    }
    glDeleteShader(vs);
    glDeleteShader(fs);
    return program;
}