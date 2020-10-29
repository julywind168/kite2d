#ifndef SERI_H
#define SERI_H


#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "charbuffer.h"


CharBuffer *
seri_pack(lua_State *L, int from, int to); 

int
seri_unpack(lua_State *L, void *data, int len);


#endif