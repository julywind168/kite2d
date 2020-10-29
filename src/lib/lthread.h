#ifndef THREAD_H
#define THREAD_H

#include "common.h"
#include "queue.h"



struct proc
{
	Queue *queue;
	_Atomic int flag;
	int cond_flag;
	pthread_mutex_t mutex;
	pthread_cond_t cond;
};


struct proc *
thread_init(lua_State *L);


int
lib_thread(lua_State *L);



#endif