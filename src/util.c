#include "util.h"
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>

/*
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
		LOG("failed to open file: %s\n", name);
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
*/


unsigned char *
load_image(const char *filename, int *width, int *height, int *channel, bool flip_vertically) {
	stbi_set_flip_vertically_on_load(flip_vertically);
	return stbi_load(filename, width, height, channel, STBI_rgb_alpha);
}