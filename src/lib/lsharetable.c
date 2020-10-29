#include <sys/time.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdio.h>
#include <malloc.h>

lua_State *STL = NULL;

/*  STL

SHARE_POINT = { "client" = void * }
SHARE_TABLE = { void *   = { }    } // on the stack top

*/

static pthread_mutex_t sharetable_mutex = PTHREAD_MUTEX_INITIALIZER;

static int init(lua_State *L)
{   
	if (STL == NULL)
	{
		STL = luaL_newstate();
		if (STL == NULL)
			return luaL_error(L, "memory error");
		lua_newtable(STL);
		lua_setfield(STL, LUA_REGISTRYINDEX, "SHARE_POINT");	// name -> void*
		lua_newtable(STL);
		lua_setfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");	// void* -> table
	}
	return 0;
}

static int l_init(lua_State *L)
{
	pthread_mutex_lock(&sharetable_mutex);

	const char *name = luaL_checkstring(L, 1);
	void *point = NULL;

	lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_POINT");
	lua_pushstring(STL, name);
	lua_rawget(STL, -2);

	switch (lua_type(STL, -1)) {
		case LUA_TNIL: {
			point = malloc(1);
			lua_pop(STL, 1); // SHARE_POINT -- top

			lua_pushstring(STL, name);
			lua_pushlightuserdata(STL, point);
			lua_settable(STL, -3);

			lua_pop(STL, 1); // pop SHARE_POINT

			lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");
			lua_pushlightuserdata(STL, point);
			lua_newtable(STL);
			lua_settable(STL, -3);
			break;
		}
		case LUA_TLIGHTUSERDATA: {
			point = lua_touserdata(STL, -1);
			lua_pop(STL, 2); // pop point, SHARE_POINT
			lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");
			break;	
		}

		default:
			break;
	}

	lua_pushlightuserdata(L, point);
	luaL_getmetatable(L, "__SHARE_TABLE");
	lua_setmetatable(L, -2);

	pthread_mutex_unlock(&sharetable_mutex);
	return 1;
}

static int setarray(lua_State *L)
{
	void *point = lua_touserdata(L, 1);
	// int index = luaL_checkinteger(L, 2);
	// int value = luaL_checkinteger(L, 3);

	pthread_mutex_lock(&sharetable_mutex);

	int int_key;
	const char * char_key;

	// lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");
	lua_pushlightuserdata(STL, point);
	lua_gettable(STL, -2);

	if (lua_type(L,2) == LUA_TNUMBER) {
		int_key = lua_tointeger(L, 2);
		lua_pushinteger(STL, int_key);
	}
	else if (lua_type(L,2) == LUA_TSTRING) {
		char_key = lua_tostring(L, 2);
		lua_pushstring(STL, char_key);
	} 

	lua_pushvalue(L, 3);

	lua_xmove(L, STL, 1);

	lua_settable(STL, -3);

	lua_pop(STL, 1); // pop table

	pthread_mutex_unlock(&sharetable_mutex);
	return 0;
}

static int getarray(lua_State *L)
{
	pthread_mutex_lock(&sharetable_mutex);

	int int_key;
	const char * char_key;
	void *point = lua_touserdata(L, 1);

	// lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");
	lua_pushlightuserdata(STL, point);
	lua_gettable(STL, -2);

	if (lua_type(L,2) == LUA_TNUMBER) {
		int_key = lua_tointeger(L, 2);
		lua_pushinteger(STL, int_key);
	}
	else if (lua_type(L,2) == LUA_TSTRING) {
		char_key = lua_tostring(L, 2);
		lua_pushstring(STL, char_key);
	} 

	lua_gettable(STL, -2);

	lua_xmove(STL, L, 1);

	lua_pop(STL, 1); // pop table

	pthread_mutex_unlock(&sharetable_mutex);

	return 1;
}

static int getlenght(lua_State *L)
{
	pthread_mutex_lock(&sharetable_mutex);

	void *point = lua_touserdata(L, 1);
	int length;

	// lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");
	lua_pushlightuserdata(STL, point);
	lua_gettable(STL, -2);

	length = luaL_len(STL, -1);
	lua_pushinteger(L, length);

	lua_pop(STL, 1);	// pop SHARE_TABLE VALUE

	pthread_mutex_unlock(&sharetable_mutex);
	return 1;
}


static int next_k(lua_State *L)
{
	pthread_mutex_lock(&sharetable_mutex);
	void *point = lua_touserdata(L, lua_upvalueindex(1));
	int ret;

	// lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");
	lua_pushlightuserdata(STL, point);
	lua_gettable(STL, -2);

	lua_pushvalue(L, lua_upvalueindex(2));
	lua_xmove(L, STL, 1);

	ret = lua_next(STL, -2);

	if (ret == 0 ) {
		lua_pushnil(L);
		lua_pushnil(L);
		lua_pushnil(L);
	}
	else {
		lua_xmove(STL, L, 2);
		lua_pushvalue(L, -2);
	}

	lua_pop(STL, 1); // pop table

	lua_replace(L, lua_upvalueindex(2));
	pthread_mutex_unlock(&sharetable_mutex);
	return 2;
}


static int pairs(lua_State *L)
{
	lua_pushvalue(L, 1);	// void *
	lua_pushnil(L);			// nil
	lua_pushcclosure(L, &next_k, 2);
	return 1;
}

static int next_i(lua_State *L)
{
	pthread_mutex_lock(&sharetable_mutex);
	void *point = lua_touserdata(L, lua_upvalueindex(1));

	// lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");
	lua_pushlightuserdata(STL, point);
	lua_gettable(STL, -2);

	int index = lua_tointeger(L, lua_upvalueindex(2));
	++ index;

	lua_pushinteger(L, index);
	lua_replace(L, lua_upvalueindex(2));

	lua_pushinteger(STL, index);
	lua_gettable(STL, -2);

	if (lua_type(STL, -1) == LUA_TNIL)
		lua_pushnil(L);
	else
		lua_pushinteger(L, index);
	lua_xmove(STL, L, 1);

	lua_pop(STL, 1); // pop table
	pthread_mutex_unlock(&sharetable_mutex);
	return 2;
}

static int ipairs(lua_State *L)
{
	lua_pushvalue(L, 1);	// void *
	lua_pushinteger(L, 0);	// 0
	lua_pushcclosure(L, &next_i, 2);
	return 1;
}

static int sharetable_insert(lua_State *L)
{
	pthread_mutex_lock(&sharetable_mutex);

	void *point = lua_touserdata(L, 1);
	int length;

	// lua_getfield(STL, LUA_REGISTRYINDEX, "SHARE_TABLE");
	lua_pushlightuserdata(STL, point);
	lua_gettable(STL, -2);

	length = luaL_len(STL, -1);
	length ++;
	lua_pushvalue(L, 2);

	lua_xmove(L, STL, 1);
	lua_rawseti(STL, -2, length);
	lua_pop(STL, 1);	// pop table

	pthread_mutex_unlock(&sharetable_mutex);
	return 0;
}

static int sharetable_remove(lua_State *L)
{
	pthread_mutex_lock(&sharetable_mutex);

	void *point = lua_touserdata(L, 1);
	int index = lua_tointeger(L, 2);

	lua_pushlightuserdata(STL, point);
	lua_gettable(STL, -2);
	int length = luaL_len(STL, -1);
	if (index <= length) {
		for (int i = index; i <= length; ++i)
		{
			if (index+1 <= length) {
				lua_rawgeti(STL, -1, index+1);
				lua_rawseti(STL, -2, index);
			} else {
				lua_pushnil(STL);
				lua_rawseti(STL, -2, index);
			}
		}

	}
	lua_pop(STL, 1);
	pthread_mutex_unlock(&sharetable_mutex);
	return 0;
}

static const struct luaL_Reg sharetable[] = {
    {"init", l_init},
    {"insert", sharetable_insert},
    {"remove", sharetable_remove},
    {NULL, NULL}
};

static const struct luaL_Reg sharetable_m[] = {
    {"__newindex", setarray},
    {"__index", getarray},
    {"__len", getlenght},
    {"__pairs", pairs},
    {"__ipairs", ipairs},
    {NULL, NULL}
};


extern int lib_sharetable(lua_State* L)
{
	init(L);
	luaL_newmetatable(L, "__SHARE_TABLE");
	luaL_setfuncs(L, sharetable_m, 0);
    luaL_newlib(L, sharetable);
    return 1;
}