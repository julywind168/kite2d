#include <stdlib.h>
#include <string.h>
#include "charbuffer.h"


CharBuffer *
charbuffer_new() {

	CharBuffer * cb = malloc(sizeof(CharBuffer));
	cb->data = malloc(128);
	cb->size = 128;
	cb->index = 0;

	return cb;
}


void
charbuffer_append(CharBuffer *cb, void *data, int sz) {

	int need = sz - (cb->size - cb->index);
	if (need > 0 ) {
		cb->size +=  (need/128 + 1) * 128;
		cb->data = realloc(cb->data, cb->size);
	}

	memcpy(cb->data + cb->index, data, sz);
	cb->index += sz;
}


void
charbuffer_free(CharBuffer *cb) {
	free(cb->data);
	free(cb);
}
