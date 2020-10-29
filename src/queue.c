#include <stdatomic.h>

#include "queue.h"

#define CHECKNULL(x) ;if(x == NULL) { perror("Malloc failed."); exit(1); }

#define LQUEUE 2048
#define LDEFAULT_SLOT 500



struct _queue{
	void *list[LQUEUE];
	uint64_t readindex;
	_Atomic uint64_t writeindex;
};


Queue *
q_initialize()
{
	Queue *q = malloc(sizeof(Queue)) CHECKNULL(q)
	memset(q, 0, sizeof(Queue));
	q->readindex = 0;
	q->writeindex = 0;

	return q;
}

bool
qpush(Queue *queue, void *data)
{
	int index;					
	int count = queue->writeindex - queue->readindex + 1; //2047	-	0    2048     2047 时超载

	if (count == LQUEUE) {
		LOG("queue overload... %llu %llu\n", queue->writeindex, queue->readindex);
		return false;
	}

	if ((count+1)%100 == 0){
		LOG("waring: queue length: %d\n", count+1);
	}

	index = atomic_fetch_add(&queue->writeindex, 1);
	index = index%LQUEUE;
	queue->list[index] = data;

	return true;
}

void *
qpop(Queue *queue)
{
	// printf("readindex: %llu\n", queue->readindex);
	int index;
	void *data;
	index = queue->readindex % LQUEUE;
	data = queue->list[index];
	if (data) {
		queue->list[index] = NULL;
		queue->readindex++;
	}
	return data;
}

void
queue_free(Queue *queue)
{  
	free(queue);
}