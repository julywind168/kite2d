#include "lsprite2d.h"



static int
lset_texcoord(lua_State *L) {
	struct sprite2d *sprite2d = lua_touserdata(L, 1);
	sprite2d->p0[6] = lua_tonumber(L, 2);
	sprite2d->p0[7] = lua_tonumber(L, 3);
	sprite2d->p1[6] = lua_tonumber(L, 4);
	sprite2d->p1[7] = lua_tonumber(L, 5);
	sprite2d->p2[6] = lua_tonumber(L, 6);
	sprite2d->p2[7] = lua_tonumber(L, 7);
	sprite2d->p3[6] = lua_tonumber(L, 8);
	sprite2d->p3[7] = lua_tonumber(L, 9);
	return 0;
}


static int
lset_color(lua_State *L) {
	struct sprite2d *sprite2d = lua_touserdata(L, 1);
	uint32_t color = lua_tointeger(L, 2);
	float color_r = COLOR_R(color);
	float color_g = COLOR_G(color);
	float color_b = COLOR_B(color);
	float color_a = COLOR_A(color);

	sprite2d->p0[2] = color_r;
	sprite2d->p0[3] = color_g;
	sprite2d->p0[4] = color_b;
	sprite2d->p0[5] = color_a;

	sprite2d->p1[2] = color_r;
	sprite2d->p1[3] = color_g;
	sprite2d->p1[4] = color_b;
	sprite2d->p1[5] = color_a;

	sprite2d->p2[2] = color_r;
	sprite2d->p2[3] = color_g;
	sprite2d->p2[4] = color_b;
	sprite2d->p2[5] = color_a;

	sprite2d->p3[2] = color_r;
	sprite2d->p3[3] = color_g;
	sprite2d->p3[4] = color_b;
	sprite2d->p3[5] = color_a;
	return 0;
}

static int
lset_position(lua_State *L) {
	struct sprite2d *sprite2d = lua_touserdata(L, 1);
	sprite2d->p0[0] = lua_tonumber(L, 2);
	sprite2d->p0[1] = lua_tonumber(L, 3);
	sprite2d->p1[0] = lua_tonumber(L, 4);
	sprite2d->p1[1] = lua_tonumber(L, 5);
	sprite2d->p2[0] = lua_tonumber(L, 6);
	sprite2d->p2[1] = lua_tonumber(L, 7);
	sprite2d->p3[0] = lua_tonumber(L, 8);
	sprite2d->p3[1] = lua_tonumber(L, 9);
	return 0;
}


static int
lset_texture(lua_State *L) {
	struct sprite2d *sprite2d = lua_touserdata(L, 1);
	uint32_t texture = lua_tointeger(L, 2);
	sprite2d->texture = texture;
	return 0;
}


static int
lset_program(lua_State *L) {
	struct sprite2d *sprite2d = lua_touserdata(L, 1);
	uint32_t program = lua_tointeger(L, 2);
	sprite2d->program = program;
	return 0;
}

;
static int
lcreate(lua_State *L) {
	struct sprite2d *sprite2d;
	uint32_t program = luaL_checkinteger(L, 1);
	uint32_t texture = luaL_checkinteger(L, 2);
	uint32_t color = luaL_checkinteger(L, 3);
	float color_r = COLOR_R(color);
	float color_g = COLOR_G(color);
	float color_b = COLOR_B(color);
	float color_a = COLOR_A(color);

	sprite2d = lua_newuserdata(L, sizeof(struct sprite2d));
	sprite2d->program = program;
	sprite2d->texture = texture;
	// position (let-top Anti-clockwise)
	sprite2d->p0[0] = lua_tonumber(L, 4);
	sprite2d->p0[1] = lua_tonumber(L, 5);
	sprite2d->p1[0] = lua_tonumber(L, 6);
	sprite2d->p1[1] = lua_tonumber(L, 7);
	sprite2d->p2[0] = lua_tonumber(L, 8);
	sprite2d->p2[1] = lua_tonumber(L, 9);
	sprite2d->p3[0] = lua_tonumber(L, 10);
	sprite2d->p3[1] = lua_tonumber(L, 11);
	//color
	sprite2d->p0[2] = color_r;
	sprite2d->p0[3] = color_g;
	sprite2d->p0[4] = color_b;
	sprite2d->p0[5] = color_a;

	sprite2d->p1[2] = color_r;
	sprite2d->p1[3] = color_g;
	sprite2d->p1[4] = color_b;
	sprite2d->p1[5] = color_a;

	sprite2d->p2[2] = color_r;
	sprite2d->p2[3] = color_g;
	sprite2d->p2[4] = color_b;
	sprite2d->p2[5] = color_a;

	sprite2d->p3[2] = color_r;
	sprite2d->p3[3] = color_g;
	sprite2d->p3[4] = color_b;
	sprite2d->p3[5] = color_a;
	// texcoord (let-top Anti-clockwise)
	sprite2d->p0[6] = lua_tonumber(L, 12);
	sprite2d->p0[7] = lua_tonumber(L, 13);
	sprite2d->p1[6] = lua_tonumber(L, 14);
	sprite2d->p1[7] = lua_tonumber(L, 15);
	sprite2d->p2[6] = lua_tonumber(L, 16);
	sprite2d->p2[7] = lua_tonumber(L, 17);
	sprite2d->p3[6] = lua_tonumber(L, 18);
	sprite2d->p3[7] = lua_tonumber(L, 19);

	return 1;
}

int
lib_sprite2d(lua_State *L)
{
	luaL_Reg l[] = {
		{"set_texcoord", lset_texcoord},
		{"set_color", lset_color},
		{"set_position", lset_position},
		{"set_texture", lset_texture},
		{"set_program", lset_program},
		{"create", lcreate},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}