/*

*/

#include "common.h"
#include "seri.h"


#define TYPE_NIL 0
#define TYPE_BOOLEAN 1
#define TYPE_NUM_SMALL 2 
#define TYPE_NUM_BIG 3
#define TYPE_NUM_REAL 4
#define TYPE_STRING 5
#define TYPE_TABLE 6
#define TYPE_QUOTE 7

#define COMBINE_TYPE(t,v) ((t) | (v) << 3)


// TODO
// 小数字优化 0 ~ 15 
// 索引类型 (保存偏移)
/*
	0. nil    		00000 000
	1. bool   		00001 001 ( 1: true 0:false )
	2. num(small)   11111 010 ( [0 ~ 31] )
	3. num(big)     00001 011 (num's length: 1 2 4 8 bits)
	4. num(real)    00000 100
	5. str          00001 101 (string length)
	6. table 		00001 110 (array length)
	7. quote		00001 111 (index length) // 引用 num(big) num(real)(偏移量 比 数字占位小一个级别)   str
*/




void pack_one(lua_State *L, int index, CharBuffer *buffer);


void pack_nil(CharBuffer *buffer) {
	uint8_t t = TYPE_NIL;
	charbuffer_append(buffer, &t, 1);
}


void pack_boolean(lua_State *L, int index, CharBuffer *buffer) {
	
	uint8_t t = COMBINE_TYPE(TYPE_BOOLEAN, lua_toboolean(L, index) ? 1 : 0);

	charbuffer_append(buffer, &t, 1);
}


void pack_number(lua_State *L, int index, CharBuffer *buffer) {

	uint8_t t;

	if (lua_isinteger(L, index)) {
		lua_Integer v = lua_tointeger(L, index);

		if (v != (int32_t)v) {
			t = COMBINE_TYPE(TYPE_NUM_BIG, 8);
			int64_t v64 = (int64_t)v;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &v64, sizeof(v64));
		} else if (v < 0) {
			t = COMBINE_TYPE(TYPE_NUM_BIG, 4);
			int32_t v32 = (int32_t)v;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &v32, sizeof(v32));
		} else if (v < 32) {
			uint8_t v8 = (uint8_t)v;
			t = COMBINE_TYPE(TYPE_NUM_SMALL, v8);
			charbuffer_append(buffer, &t, 1);
		} else if (v < 0x100) {
			t = COMBINE_TYPE(TYPE_NUM_BIG, 1);
			uint8_t v8 = (uint8_t)v;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &v8, sizeof(v8));
		} else if (v < 0x10000) {
			t = COMBINE_TYPE(TYPE_NUM_BIG, 2);
			uint16_t v16 = (uint16_t)v;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &v16, sizeof(v16));
		} else {
			t = COMBINE_TYPE(TYPE_NUM_BIG, 4);
			uint32_t v32 = (uint32_t)v;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &v32, sizeof(v32));
		}

	} else {
		t = TYPE_NUM_REAL;
		double v = (double)lua_tonumber(L, index);
		charbuffer_append(buffer, &t, 1);
		charbuffer_append(buffer, &v, sizeof(v));
	}
}


void pack_string(lua_State *L, int index, CharBuffer *buffer) {
	
	uint8_t t;
	size_t sz = 0;

	lua_pushvalue(L, index);
	lua_rawget(L, 1);

	if (lua_isinteger(L, -1)) {
		uint64_t _offset = lua_tointeger(L, -1);
		if (_offset < 0x100) {
			t = COMBINE_TYPE(TYPE_QUOTE, 1);
			uint8_t offset = (uint8_t)_offset;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &offset, sizeof(uint8_t));
		} else if (_offset < 0x10000) {
			t = COMBINE_TYPE(TYPE_QUOTE, 2);
			uint16_t offset = (uint16_t)_offset;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &offset, sizeof(uint16_t));			
		} else if (_offset < 0x100000000) {
			t = COMBINE_TYPE(TYPE_QUOTE, 4);
			uint32_t offset = (uint32_t)_offset;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &offset, sizeof(uint32_t));
		} else {
			t = COMBINE_TYPE(TYPE_QUOTE, 8);
			uint64_t offset = (uint64_t)_offset;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &offset, sizeof(uint64_t));
		}
		lua_pop(L, 1);
	} else { 
		lua_pop(L, 1);

		lua_pushvalue(L, index);
		lua_pushinteger(L, buffer->index);
		lua_rawset(L, 1);		// string -> postion

		const char * str = lua_tolstring(L, index, &sz);

		if (sz < 0x100) {
			t = COMBINE_TYPE(TYPE_STRING, 1);
			uint8_t len = (uint8_t)sz;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &len, sizeof(uint8_t));
		} else if (sz < 0x10000) {
			t = COMBINE_TYPE(TYPE_STRING, 2);
			uint16_t len = (uint16_t)sz;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &len, sizeof(uint16_t));
		} else if (sz < 0x100000000) {
			t = COMBINE_TYPE(TYPE_STRING, 4);
			uint32_t len = (uint32_t)sz;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &len, sizeof(uint32_t));
		} else {
			t = COMBINE_TYPE(TYPE_STRING, 8);
			uint64_t len = (uint64_t)sz;
			charbuffer_append(buffer, &t, 1);
			charbuffer_append(buffer, &len, sizeof(uint64_t));
		}
		charbuffer_append(buffer, (void *)str, (int)sz);
	}
}


void pack_table(lua_State *L, int index, CharBuffer *buffer) {

	uint8_t t = TYPE_TABLE;

	charbuffer_append(buffer, &t, 1);

	lua_pushnil(L);
	while (lua_next(L, index) != 0) {
		pack_one(L, index+1, buffer);
		pack_one(L, index+2, buffer);
		lua_pop(L, 1);
	}
	pack_nil(buffer);
}


void pack_one(lua_State *L, int index, CharBuffer *buffer) {

	switch (lua_type(L, index)) {
		case LUA_TNIL:
			pack_nil(buffer);
			break;
		case LUA_TBOOLEAN:
			pack_boolean(L, index, buffer);
			break;
		case LUA_TNUMBER:
			pack_number(L, index, buffer);
			break;
		case LUA_TSTRING:
			pack_string(L, index, buffer);
			break;
		case LUA_TTABLE:
			pack_table(L, index, buffer);
			break;
		default:
			fprintf(stderr, "error: scorpio.pack unable this type: %s\n", lua_typename(L, lua_type(L, index)));
			exit(1);
			break;
	}
}


CharBuffer * seri_pack(lua_State *L, int from, int to) {

	CharBuffer *buffer = charbuffer_new();


	lua_newtable(L);  // 记录打包过的数字, 字符串
	lua_insert(L, 1);


	for (int i = from+1; i <= to+1; ++i)
	{
		pack_one(L, i, buffer);
	}

	lua_pop(L, 1);

	return buffer;
}


/*
	unpack
*/

typedef struct {
	void *data;
	int len;
	void *ptr;
} ReadBuffer;




void unpack_one(lua_State *L, ReadBuffer *buffer) {
	
	uint8_t t = *(uint8_t *)(buffer->ptr);



	buffer->ptr += 1;

	switch(t & 0x7) {
		case TYPE_NIL:
			lua_pushnil(L);
			break;
		case TYPE_BOOLEAN:
			lua_pushboolean(L, t>>3);
			break;
		case TYPE_NUM_SMALL:
			lua_pushinteger(L, t>>3);
			break;
		case TYPE_NUM_BIG: {
			switch(t>>3) {
				case 1: {
					uint8_t v8 = *(uint8_t *)(buffer->ptr);
					buffer->ptr += sizeof(uint8_t);
					lua_pushinteger(L, v8);
					break;
				}
				case 2: {
					uint16_t v16 = *(uint16_t *)(buffer->ptr);
					buffer->ptr += sizeof(uint16_t);
					lua_pushinteger(L, v16);
					break;
				}
				case 4: {
					int32_t v32 = *(int32_t *)(buffer->ptr);
					buffer->ptr += sizeof(int32_t);
					lua_pushinteger(L, v32);
					break;
				}
				case 8: {
					int64_t v64 = *(int64_t *)(buffer->ptr);
					buffer->ptr += sizeof(int64_t);
					lua_pushinteger(L, v64);
					break;
				}
			}
			break;
		}
		case TYPE_NUM_REAL: {
			double v = *(double *)(buffer->ptr);
			buffer->ptr += sizeof(double);
			lua_pushnumber(L, v);
			break;
		}
		case TYPE_STRING: {
			switch(t>>3) {
				case 1: {
					uint8_t len = *(uint8_t *)(buffer->ptr);
					buffer->ptr += sizeof(uint8_t);
					lua_pushlstring(L, buffer->ptr, len);
					buffer->ptr += len;
					break;
				}
				case 2: {
					uint16_t len = *(uint16_t *)(buffer->ptr);
					buffer->ptr += sizeof(uint16_t);
					lua_pushlstring(L, buffer->ptr, len);
					buffer->ptr += len;
					break;
				}
				case 4: {
					uint32_t len = *(uint32_t *)(buffer->ptr);
					buffer->ptr += sizeof(uint32_t);
					lua_pushlstring(L, buffer->ptr, len);
					buffer->ptr += len;
					break;
				}
				case 8: {
					uint64_t len = *(uint32_t *)(buffer->ptr);
					buffer->ptr += sizeof(uint64_t);
					lua_pushlstring(L, buffer->ptr, len);
					buffer->ptr += len;
					break;	
				}
			}
			break;
		}
		case TYPE_TABLE: {
			luaL_checkstack(L,LUA_MINSTACK,NULL);
			lua_newtable(L);

			for (;;)
			{
				unpack_one(L, buffer);
				if (lua_isnil(L, -1)) {
					lua_pop(L, 1);
					return;
				}
				unpack_one(L, buffer);
				lua_rawset(L, -3);
			}
			break;
		}
		case TYPE_QUOTE: {

			switch(t>>3) {
				case 1: {
					uint8_t offset = *(uint8_t *)(buffer->ptr);
					void *tmp = buffer->ptr + sizeof(uint8_t);
					buffer->ptr = buffer->data + offset;
					unpack_one(L, buffer);
					buffer->ptr = tmp;
					break;
				}
				case 2: {
					uint16_t offset = *(uint16_t *)(buffer->ptr);
					void *tmp = buffer->ptr + sizeof(uint16_t);
					buffer->ptr = buffer->data + offset;
					unpack_one(L, buffer);
					buffer->ptr = tmp;
					break;
				}
				case 4: {
					uint32_t offset = *(uint32_t *)(buffer->ptr);
					void *tmp = buffer->ptr + sizeof(uint32_t);
					buffer->ptr = buffer->data + offset;
					unpack_one(L, buffer);
					buffer->ptr = tmp;
					break;
				}
				case 8: {
					uint64_t offset = *(uint64_t *)(buffer->ptr);
					void *tmp = buffer->ptr + sizeof(uint64_t);
					buffer->ptr = buffer->data + offset;
					unpack_one(L, buffer);
					buffer->ptr = tmp;
					break;
				}
			}
			break;
		}
	}	
}


int seri_unpack(lua_State *L, void *data, int len) {

	int n = 0;
	ReadBuffer buffer = { data, len, data };

	while ((buffer.data + len) != buffer.ptr) {
		unpack_one(L, &buffer);
		n++;
	}

	return n;
}