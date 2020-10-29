#ifndef STAR_QUEUE_H
#define STAR_QUEUE_H

#include "common.h"

typedef struct _queue Queue;



Queue *
q_initialize();


bool
qpush(Queue *queue, void *data);


void *
qpop(Queue *queue);


void
queue_free(Queue *queue);



#endif