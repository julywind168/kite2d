#include "laudio.h"
#include "game.h"
#define STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"

extern Game *G;


static int
ldelete_buffer(lua_State *L) {
	ALuint buffer = luaL_checkinteger(L, 1);
	alDeleteBuffers(1, &buffer);
	return 0;
}


static int
lplay(lua_State *L) {
	ALuint source = luaL_checkinteger(L, 1);
	ALuint buffer = luaL_checkinteger(L, 2);
	alSourcei(source, AL_BUFFER, buffer);
	alSourcePlay(source);
	return 0;
}


static int
lbuffer(lua_State *L) {
	const char *filename;
	ALuint buffer;
	short *data;
	int channels, sample_rate, sz;

	filename = luaL_checkstring(L, 1);
	alGenBuffers(1, &buffer);
	sz = stb_vorbis_decode_filename(filename, &channels, &sample_rate, &data);
	if (sz == -1) return luaL_error(L,  "failed to load %s", filename);
	alBufferData(buffer, AL_FORMAT_STEREO16, data, sz*2*sizeof(short), sample_rate);

	lua_pushinteger(L, buffer);
	return 1;
}


static int
lsource_set_loop(lua_State *L) {
	ALuint source = luaL_checkinteger(L, 1);
	int isloop = lua_toboolean(L, 2);
	alSourcei(source, AL_LOOPING, isloop);
	return 0;
}


static int
lsource(lua_State *L) {
	int isloop = lua_toboolean(L, 1);
	ALuint source;
	alGenSources(1, &source);
	alSourcef(source, AL_PITCH, 1);
	alSourcef(source, AL_GAIN, 1);
	alSource3f(source, AL_POSITION, 0, 0, 0);
	alSource3f(source, AL_VELOCITY, 0, 0, 0);
	alSourcei(source, AL_LOOPING, isloop);
	lua_pushinteger(L, source);
	return 1;
}


static int
ldelete_source(lua_State *L) {
	ALuint source = luaL_checkinteger(L, 1);
	alDeleteSources(1, &source);
	return 0;
}


int
lib_audio(lua_State *L)
{
	luaL_Reg l[] = {
		{"play", lplay},
		{"delete_buffer", ldelete_buffer},
		{"buffer", lbuffer},

		{"delete_source", ldelete_source},
		{"source_set_loop", lsource_set_loop},
		{"source", lsource},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}