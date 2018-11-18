local core = require "graphics.core"
local font_core = require "font.core"

local textures = {}
local fonts = {}

local function get_font(filename, size)
	local size = size or 48
	local font = fonts[filename]
	if font then return font end

	font = { face = font_core.face(filename, size), size = size, loaded = {} }

	function font.chars(string)
		local r = {}
		for _,id in utf8.codes(string) do
			local char = font.loaded[id]
			if not char then
				char = font_core.char(font.face, id)
				font.loaded[id] = char
			end
			table.insert(r, char)
		end
		return r
	end

	fonts[filename] = font
	return font
end

local function get_texture(texname)
	local tex = textures[texname]
	if tex then return tex end

	tex = core.texture(texname)
	textures[texname] = tex
	return tex
end


local M = {}


function M.draw_text(fontname, string, x, y, size, color)
	local font = get_font(fontname)
	local chars = font.chars(string)
	local scale = size/font.size
	core.draw_text(x, y, scale, chars, color)
end


function M.sprite(t)
	local self = {
		x = t.x or 0,
		y = t.y or 0,
		w = assert(t.w),
		h = assert(t.h),
		anchorx = t.anchorx,			--	0~1
		anchory = t.anchory,			--	0~1
		rotate = t.rotate or 0,			--  0~360
		color = t.color	or 0xffffffff,
		texname = t.texname or "resource/white.png",
		texcoord = t.texcoord,
	}

	-- 4个点的世界坐标 [p1.xy p2.xy p3.xy p4.xy] 左上开始逆时针
	self.aabb = {{x = self.x - self.w/2, y = self.y + self.h/2},	
				 {x = self.x - self.w/2, y = self.y - self.h/2},
				 {x = self.x + self.w/2, y = self.y - self.h/2},
				 {x = self.x + self.w/2, y = self.y + self.h/2}}

	local texture = get_texture(self.texname)
	local vao, vbo = core.sprite(
		self.aabb[1].x, self.aabb[1].y,
		self.aabb[2].x, self.aabb[2].y,
		self.aabb[3].x, self.aabb[3].y,
		self.aabb[4].x, self.aabb[4].y,
		self.texcoord and table.unpack(self.texcoord))

	local function update_aabb()
		self.aabb[1].x = self.x - self.w/2
		self.aabb[1].y = self.y + self.h/2
		self.aabb[2].x = self.x - self.w/2
		self.aabb[2].y = self.y - self.h/2
		self.aabb[3].x = self.x + self.w/2
		self.aabb[3].y = self.y - self.h/2
		self.aabb[4].x = self.x + self.w/2
		self.aabb[4].y = self.y + self.h/2

		core.sprite_aabb(vbo,
			self.aabb[1].x, self.aabb[1].y,
			self.aabb[2].x, self.aabb[2].y,
			self.aabb[3].x, self.aabb[3].y,
			self.aabb[4].x, self.aabb[4].y)
	end

	function self.draw()
		core.draw_sprite(vao, texture)
	end

	function self.texture(texname, texcoord)
		texture = get_texture(texname)
	end

	local set = {}

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


return setmetatable(M, {__index = core})