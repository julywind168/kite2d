#include "util.h"

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

GLuint loadbmp(const char * imagepath) {
	// Data read from the header of the BMP file
	unsigned char header[54]; // Each BMP file begins by a 54-bytes header
	unsigned int dataPos;     // Position in the file where the actual data begins
	unsigned int width, height;
	unsigned int imageSize;   // = width*height*3
	// Actual RGB data
	unsigned char * data;

	FILE * file = fopen(imagepath,"rb");
	if (!file){printf("Image could not be opened\n"); return 0;}
	if (fread(header, 1, 54, file) != 54) {
	    printf("not a correct bmp image\n");
	    return 0;
	}
	if (header[0]!='B' || header[1]!='M'){
	   	printf("not a correct bmp image\n");
	    return 0;
	}
	dataPos    = *(int*)&(header[0x0A]);
	imageSize  = *(int*)&(header[0x22]);
	width      = *(int*)&(header[0x12]);
	height     = *(int*)&(header[0x16]);
	if (imageSize==0)
		imageSize = width*height*3;
	if (dataPos==0)
		dataPos = 54;

	data = malloc(sizeof(unsigned char)*imageSize);
	fread(data,1,imageSize,file);
	fclose(file);

	// Create one OpenGL texture
	GLuint textureID;
	glGenTextures(1, &textureID);

	// "Bind" the newly created texture : all future texture functions will modify this texture
	glBindTexture(GL_TEXTURE_2D, textureID);

	// Give the image to OpenGL
	glTexImage2D(GL_TEXTURE_2D, 0,GL_RGB, width, height, 0, GL_BGR, GL_UNSIGNED_BYTE, data);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

	glBindTexture(GL_TEXTURE_2D, 0);

	return textureID;
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
create_program() {
	GLuint program = glCreateProgram();
	GLuint vs = create_shader("shader/shader.vs", GL_VERTEX_SHADER);
	GLuint fs = create_shader("shader/shader.fs", GL_FRAGMENT_SHADER);

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