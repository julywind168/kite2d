#include "lmatrix.h"
#include "lprogram.h"
#include "game.h"


extern struct game *G;


static int
luniform_4f(lua_State *L) {
	uint32_t id;
	float a, b, c, d;

	G->renderer->flush();
	id = luaL_checkinteger(L, 1);
	a = lua_tonumber(L, 2);
	b = lua_tonumber(L, 3);
	c = lua_tonumber(L, 4);
	d = lua_tonumber(L, 5);
	glUniform4f(id, a, b, c, d);
	return 0;
}

static int
luniform_3f(lua_State *L) {
	uint32_t id;
	float a, b, c;

	G->renderer->flush();
	id = luaL_checkinteger(L, 1);
	a = lua_tonumber(L, 2);
	b = lua_tonumber(L, 3);
	c = lua_tonumber(L, 4);
	glUniform3f(id, a, b, c);
	return 0;
}


static int
luniform_2f(lua_State *L) {
	uint32_t id;
	float a, b;

	G->renderer->flush();
	id = luaL_checkinteger(L, 1);
	a = lua_tonumber(L, 2);
	b = lua_tonumber(L, 3);
	glUniform2f(id, a, b);
	return 0;
}


static int
luniform_1f(lua_State *L) {
	uint32_t id;
	float a;

	G->renderer->flush();
	id = luaL_checkinteger(L, 1);
	a = lua_tonumber(L, 2);
	glUniform1f(id, a);
	return 0;
}


static int
luniform_1i(lua_State *L) {
	uint32_t id;
	int n;

	G->renderer->flush();
	id = luaL_checkinteger(L, 1);
	n = lua_tointeger(L, 2);
	glUniform1i(id, n);
	return 0;
}


static int
luniform_1ui(lua_State *L) {
	uint32_t id;
	uint32_t n;

	G->renderer->flush();
	id = luaL_checkinteger(L, 1);
	n = lua_tointeger(L, 2);
	glUniform1ui(id, n);
	return 0;
}


static int
luniform_matrix4fv(lua_State *L) {
	uint32_t id;
	struct mat4x4 *m;

	G->renderer->flush();
	id = luaL_checkinteger(L, 1);
	m = lua_touserdata(L, 2);
	glUniformMatrix4fv(id, 1, GL_FALSE, (const float *)m);
	return 0;
}


static int
luniform_location(lua_State *L) {
	uint32_t prog, id;
	const char *name;

	G->renderer->flush();
	prog = luaL_checkinteger(L, 1);
	name = luaL_checkstring(L, 2);
	id = glGetUniformLocation(prog, name);
	lua_pushinteger(L, id);
	return 1;
}


static int
lactive(lua_State *L) {
	uint32_t prog = luaL_checkinteger(L, 1);
	G->renderer->flush();
	G->renderer->use_program(prog);
	return 0;
}


uint32_t
create_shader(GLenum type, const char *data, int sz) {
	GLuint shader = glCreateShader(type);
	if (shader == 0) {
		LOG("failed to create shader\n");
		exit(1);
	}
	glShaderSource(shader, 1, &data, &sz);
	glCompileShader(shader);

	GLint success;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
	if (!success) {
		GLchar info[1024];
		glGetShaderInfoLog(shader, 1024, NULL, info);
		LOG("faield to compile shader[%d], '%s'\n", type, info);
		exit(1);
	}
	return shader;
}


static int
lcreate(lua_State *L) {
	uint32_t program, vs, fs;
	const char *vs_text;
	const char *fs_text;
	size_t vs_sz, fs_sz;
	vs_text = luaL_checklstring(L, 1, &vs_sz);
	fs_text = luaL_checklstring(L, 2, &fs_sz);

	vs = create_shader(GL_VERTEX_SHADER, vs_text, vs_sz);
	fs = create_shader(GL_FRAGMENT_SHADER, fs_text, fs_sz);
	program = glCreateProgram();
	glAttachShader(program, fs);
	glAttachShader(program, vs);
	glLinkProgram(program);

	GLint success = 0;
	GLchar err_info[1024] = { 0 };
	glGetProgramiv(program, GL_LINK_STATUS, &success);
	if (!success) {
		glGetProgramInfoLog(program, sizeof(err_info), NULL, err_info);
		LOG("failed to link shader program: '%s'\n", err_info);
		exit(1);
	}
	glDeleteShader(vs);
	glDeleteShader(fs);
	lua_pushinteger(L, program);
	return 1;
}


int
lib_program(lua_State *L)
{
	luaL_Reg l[] = {
		{"uniform_4f", luniform_4f},
		{"uniform_3f", luniform_3f},
		{"uniform_2f", luniform_2f},
		{"uniform_1f", luniform_1f},
		{"uniform_1ui", luniform_1ui},
		{"uniform_1i", luniform_1i},
		{"uniform_matrix4fv", luniform_matrix4fv},
		{"uniform_location", luniform_location},
		{"active", lactive},
		{"create", lcreate},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}