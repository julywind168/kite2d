local graphics = require "graphics.core"


local SP_CUR_COLOR = 0xffffffff
local textures = {}


local function get_texture(texname)
	local tex = textures[texname]
	if tex then return tex end

	tex = graphics.texture(texname)
	textures[texname] = tex
	return tex
end

local function rotate(x0, y0, x, y, a)
	a = a * math.pi/180
	local x1 = (x-x0)*math.cos(a) - (y-y0)*math.sin(a) + x0
	local y1 = (x-x0)*math.sin(a) + (y-y0)*math.cos(a) + y0
	return x1, y1
end


local function set_sp_color(c)
	if c ~= SP_CUR_COLOR then
		SP_CUR_COLOR = c
		graphics.set_sp_color(c)
	end
end

local function sprite(t)
	local self = {
		x = t.x or 0,
		y = t.y or 0,
		w = assert(t.w),
		h = assert(t.h),
		angle = t.angle or 0,			--  0~360 逆时针
		anchorx = t.anchorx or 0.5,		--	锚点:左下角(0,0) 右上角(1,1)
		anchory = t.anchory or 0.5,
		color = t.color	or 0xffffffff,
		texname = t.texname or "resource/white.png",
		texcoord = t.texcoord or {0,1, 0,0, 1,0, 1,1},
		aabb = {{}, {}, {}, {}},
		camera = (t.camera ~= false) and true or false
	}

	-- 4个点的世界坐标 [p1.xy p2.xy p3.xy p4.xy] 左上开始逆时针
	self.aabb[1].x, self.aabb[1].y = rotate(self.x, self.y, self.x-self.anchorx*self.w, self.y+(1-self.anchory)*self.h, self.angle)
	self.aabb[2].x, self.aabb[2].y = rotate(self.x, self.y, self.x-self.anchorx*self.w, self.y-self.anchory*self.h, self.angle)
	self.aabb[3].x, self.aabb[3].y = rotate(self.x, self.y, self.x+(1-self.anchorx)*self.w, self.y-self.anchory*self.h, self.angle)
	self.aabb[4].x, self.aabb[4].y = rotate(self.x, self.y, self.x+(1-self.anchorx)*self.w, self.y+(1-self.anchory)*self.h, self.angle)

	local texture = get_texture(self.texname)
	local vao, vbo = graphics.sprite(
		self.aabb[1].x, self.aabb[1].y,
		self.aabb[2].x, self.aabb[2].y,
		self.aabb[3].x, self.aabb[3].y,
		self.aabb[4].x, self.aabb[4].y,
		self.texcoord and table.unpack(self.texcoord))

	local function update_aabb()
		self.aabb[1].x, self.aabb[1].y = rotate(self.x, self.y, self.x-self.anchorx*self.w, self.y+(1-self.anchory)*self.h, self.angle)
		self.aabb[2].x, self.aabb[2].y = rotate(self.x, self.y, self.x-self.anchorx*self.w, self.y-self.anchory*self.h, self.angle)
		self.aabb[3].x, self.aabb[3].y = rotate(self.x, self.y, self.x+(1-self.anchorx)*self.w, self.y-self.anchory*self.h, self.angle)
		self.aabb[4].x, self.aabb[4].y = rotate(self.x, self.y, self.x+(1-self.anchorx)*self.w, self.y+(1-self.anchory)*self.h, self.angle)

		graphics.update_sprite_aabb(vbo,
			self.aabb[1].x, self.aabb[1].y,
			self.aabb[2].x, self.aabb[2].y,
			self.aabb[3].x, self.aabb[3].y,
			self.aabb[4].x, self.aabb[4].y)
	end

	function self.draw()
		set_sp_color(self.color)
		graphics.draw_sprite(vao, self.camera, texture)
	end

	local set = {}

	function set.texture(texname, texcoord)
		texture = get_texture(texname)
		self.texcoord = texcoord or {0,1, 0,0, 1,0, 1,1}
		if texcoord then
			core.update_sprite_texcoord(vbo, table.unpack(texcoord))
		end
	end

	function set.angle(a)
		self.angle = a
		update_aabb()
	end

	function set.x(x)
		self.x = x
		update_aabb()
	end

	function set.y(y)
		self.y = y
		update_aabb()
	end

	return setmetatable(self, {__call = function (_, k, v)
		local f = set[k]
		if f then f(v) end
	end})
end

return sprite