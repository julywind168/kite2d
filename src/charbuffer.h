#ifndef CHARBUFF_H
#define CHARBUFF_H


typedef struct
{
	char *data;
	int size;
	int index;
} CharBuffer;



CharBuffer *
charbuffer_new();


void
charbuffer_append(CharBuffer *cb, void *data, int sz);


void
charbuffer_free(CharBuffer *cb);



#endif