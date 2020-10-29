#include "common.h"
#include "charbuffer.h"
#include "queue.h"
#include "seri.h"

#include "lkite.h"
#include "lgraphics.h"
#include "lsprite2d.h"
#include "lmatrix.h"
#include "lprogram.h"
#include "laudio.h"
#include "lthread.h"
#include "lsharetable.h"

#define RUNNING 0
#define BLOCKED 1


static int
lreceive(lua_State *L)
{
	CharBuffer *buffer = NULL;
	struct proc *self;

	self = (struct proc *)lua_tointeger(L, 1);
	buffer = qpop(self->queue);

	if (buffer) {
		return seri_unpack(L, buffer->data, buffer->index);
	} else {
		self->cond_flag = 1;
		self->flag = BLOCKED;

		do {
			pthread_cond_wait(&self->cond, &self->mutex);
		} while (self->cond_flag == 1);

		self->flag = RUNNING;
		buffer = qpop(self->queue);
		assert(buffer);
		return seri_unpack(L, buffer->data, buffer->index);
	}
}

static int
lreceive_noblock(lua_State *L)
{
	CharBuffer *buffer = NULL;
	struct proc *self;

	self = (struct proc *)lua_tointeger(L, 1);
	buffer = qpop(self->queue);

	if (buffer) {
		return seri_unpack(L, buffer->data, buffer->index);
	} else {
		return 0;
	}
}


static int
lsend(lua_State *L) {
	struct proc *to;
	void *msg;
	to = (struct proc *)lua_tointeger(L, 1);
	msg = (void *)seri_pack(L, 2, lua_gettop(L));
	assert(qpush(to->queue, msg));
	if (to->flag == BLOCKED) {
		to->cond_flag = 0;
		pthread_cond_signal(&to->cond);
	}
	return 0;
}


static void *
ll_thread(void *arg)
{
	lua_State *L = (lua_State *)arg;

	// 打开 标准库
	luaL_openlibs(L);
	luaL_requiref(L, "kite.core", lib_kite, 0);
	luaL_requiref(L, "graphics.core", lib_graphics, 0);
	luaL_requiref(L, "sprite2d.core", lib_sprite2d, 0);
	luaL_requiref(L, "matrix.core", lib_matrix, 0);
	luaL_requiref(L, "program.core", lib_program, 0);
	luaL_requiref(L, "audio.core", lib_audio, 0);
	luaL_requiref(L, "thread.core", lib_thread, 0);
	luaL_requiref(L, "sharetable.core", lib_sharetable, 0);
	lua_pop(L, 8);

	// 调用主程序块
	if (lua_pcall(L,0, 0, 0) != 0) {
		LOG("thread error: %s\n", lua_tostring(L, -1));
	}

	lua_close(L);
	return NULL;
}


struct proc *
thread_init(lua_State *L){
	struct proc *proc;
	proc = (struct proc *)lua_newuserdata(L, sizeof(struct proc));
	lua_setfield(L, LUA_REGISTRYINDEX, "_PROC");
	lua_pushinteger(L, (uint64_t)proc);
	lua_setfield(L, LUA_REGISTRYINDEX, "_PROC_ID");

	proc->flag = RUNNING;
	proc->cond_flag = 0;
	proc->queue = q_initialize();
	pthread_mutex_init(&proc->mutex, NULL);
	pthread_cond_init(&proc->cond, NULL);
	return proc;
}


static int
lfork(lua_State *L) {
	struct proc *proc;
	pthread_t thread;
	const char *filename;
	lua_State *L1;

	filename = luaL_checkstring(L, 1);
	L1 = luaL_newstate();

	if (L1 == NULL)
		return luaL_error(L, "unable to create new state");
	proc = thread_init(L1);

	if (luaL_loadfile(L1, filename) != 0 )
		return luaL_error(L, "error fork thread: %s", lua_tostring(L1, -1));
	if (pthread_create(&thread, NULL, ll_thread, L1) != 0)
		return luaL_error(L, "unable to create new state");

	pthread_detach(thread);

	lua_pushinteger(L, (uint64_t)proc);
    return 1;
}


int
lib_thread(lua_State *L)
{
	luaL_Reg l[] = {
		{"receive_noblock", lreceive_noblock},
		{"receive", lreceive},
		{"send", lsend},
		{"fork", lfork},
		{NULL, NULL}
	};
	luaL_newlib(L, l);

	lua_getfield(L, LUA_REGISTRYINDEX, "_PROC_ID");
	lua_setfield(L, -2, "self");

	return 1;
}