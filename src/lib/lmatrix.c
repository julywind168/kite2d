#include "lmatrix.h"



static int
lortho(lua_State *L) {
	struct mat4x4 *m;
	float l, r, b, t, n, f;
	l = lua_tonumber(L, 1);
	r = lua_tonumber(L, 2);
	b = lua_tonumber(L, 3);
	t = lua_tonumber(L, 4);
	n = lua_tonumber(L, 5);
	f = lua_tonumber(L, 6);

	m = lua_newuserdata(L, sizeof(struct mat4x4));
	m->m0[0] = 2.f / (r - l);
	m->m0[1] = m->m0[2] = m->m0[3] = 0.f;

	m->m1[1] = 2.f / (t - b);
	m->m1[0] = m->m1[2] = m->m1[3] = 0.f;

	m->m2[2] = -2.f / (f - n);
	m->m2[0] = m->m2[1] = m->m2[3] = 0.f;

	m->m3[0] = -(r + l) / (r - l);
	m->m3[1] = -(t + b) / (t - b);
	m->m3[2] = -(f + n) / (f - n);
	m->m3[3] = 1.f;

	return 1;
}


int
lib_matrix(lua_State *L)
{
	luaL_Reg l[] = {
		{"ortho", lortho},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}