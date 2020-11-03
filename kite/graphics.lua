local core = require 'graphics.core'
local sprite2d = require "sprite2d.core"
local texmgr = require "kite.manager.texture"
local fontmgr = require "kite.manager.font"
local program = (require "kite.manager.program").get_sprite_program()
local rotate = require "kite.util".rotate


local M = {}

----------------------------------------------------------------------------
-- sprite start
----------------------------------------------------------------------------
local function sprite_transform(sp)
	local w = sp.width
	local h = sp.height

	local x0 = sp.x
	local y0 = sp.y

	local x2 = x0 - sp.anchor.x*w
	local y2 = y0 - sp.anchor.y*h

	local x1 = x2
	local y1 = y2 + h

	local x3 = x1 + w
	local y3 = y2

	local x4 = x3
	local y4 = y1

	if sp.angle ~= 0 then
		x1, y1 = rotate(x0, y0, sp.angle, x1, y1)
		x2, y2 = rotate(x0, y0, sp.angle, x2, y2)
		x3, y3 = rotate(x0, y0, sp.angle, x3, y3)
		x4, y4 = rotate(x0, y0, sp.angle, x4, y4)
	end

	return x1,y1, x2,y2, x3,y3, x4,y4
end


local function sprite_flip_h(sp)
	sp.texcoord[1],sp.texcoord[7] = sp.texcoord[7], sp.texcoord[1]
	sp.texcoord[2],sp.texcoord[8] = sp.texcoord[8], sp.texcoord[2]
	sp.texcoord[3],sp.texcoord[5] = sp.texcoord[5], sp.texcoord[3]
	sp.texcoord[4],sp.texcoord[6] = sp.texcoord[6], sp.texcoord[4]
end


local function sprite_flip_v(sp)
	sp.texcoord[1],sp.texcoord[3] = sp.texcoord[3], sp.texcoord[1]
	sp.texcoord[2],sp.texcoord[4] = sp.texcoord[4], sp.texcoord[2]
	sp.texcoord[7],sp.texcoord[5] = sp.texcoord[5], sp.texcoord[7]
	sp.texcoord[8],sp.texcoord[6] = sp.texcoord[6], sp.texcoord[8]
end


function M.sprite(sp)
	local tex = texmgr.query(assert(sp.image))
	sp.color = sp.color or 0xffffffff
	sp.angle = sp.angle or 0
	sp.texcoord = sp.texcoord or {0,1, 0,0, 1,0, 1,1}
	sp.hflip = sp.hflip and true or false
	sp.vflip = sp.vflip and true or false
	sp.anchor = sp.anchor or {x = 0.5, y = 0.5}

	if sp.hflip then
		sprite_flip_h(sp)
	end
	if sp.vflip then
		sprite_flip_v(sp)
	end

	local x1, y1, x2, y2, x3, y3, x4, y4 = sprite_transform(sp)
	local id = sprite2d.create(program.id, tex.id, sp.color, x1, y1, x2, y2, x3, y3, x4, y4, table.unpack(sp.texcoord))

	function sp.set_color(color)
		sp.color = color
		sprite2d.set_color(id, color)
	end

	function sp.set_image(filename, coord)
		tex = texmgr.query(filename)
		sprite2d.set_texture(id, tex.id)
		if coord then
			sp.set_texcoord(coord)
		end
	end

	function sp.set_texcoord(coord)
		sp.texcoord = coord
		sprite2d.set_texcoord(id, table.unpack(coord))
	end

	function sp.set_anchor(anchor)
		sp.anchor = anchor
		sp.update_transform()
	end

	function sp.update_transform()
		local x1, y1, x2, y2, x3, y3, x4, y4 = sprite_transform(sp)
		sprite2d.set_position(id, x1, y1, x2, y2, x3, y3, x4, y4)
	end

	function sp.flip_h()
		sprite_flip_h(sp)
		sprite2d.set_texcoord(id, table.unpack(sp.texcoord))
		sp.hflip = not sp.hflip
	end

	function sp.flip_v()
		sprite_flip_v(sp)
		sprite2d.set_texcoord(id, table.unpack(sp.texcoord))
		sp.hflip = not sp.hflip
	end

	function sp.draw()
		core.draw(id)
	end

	return sp
end



----------------------------------------------------------------------------
-- label start
----------------------------------------------------------------------------
local BORDER_WIDTH = 2


local function label_get_text_width(font, text, xscale)
	local x = 0
	local w = 0
	local xadvance = 0
	local last_w = 0

	for _,id in utf8.codes(text) do
		local c = assert(font.char[id])
		x = x + xadvance
		last_w = c.width
		xadvance = c.xadvance*xscale 
	end

	return math.floor(x + BORDER_WIDTH + last_w * xscale)
end

-- 第一个字符左上角的坐标
local function label_start_xy(x, y, text_width, text_height, xalign, yalign, size, yscale)
	if xalign == "center" then
		x = x - text_width/2
	elseif xalign == "right" then
		x = x - text_width
	end

	if yalign == "top" then
		y = y - text_height/2
	elseif yalign == "bottom" then
		y = y + text_height/2
	end
	
	y = y - math.floor(yscale) + size//2 
	return x + BORDER_WIDTH/2, y
end

local function label_foreach_text(lab, font, f)
	local text = lab.text
	local xscale = (lab.size/font.info.size) * lab.xscale
	local yscale = (lab.size/font.info.size) * lab.yscale
	local text_w = label_get_text_width(font, text, xscale)
	local text_h = font.common.lineHeight * lab.yscale
	local x0, y0 = label_start_xy(lab.x, lab.y, text_w, text_h, lab.xalign, lab.yalign, lab.size, yscale)

	local xadvance = 0
	local x, y, w, h

	for i,code in utf8.codes(text) do
		x0 = x0 + xadvance
		local c = assert(font.char[code])
		w = c.width * xscale
		h = c.height * yscale
		x = x0 + w / 2
		y = y0 - c.yoffset * yscale - h/2

		if lab.angle ~= 0 then
			x, y = rotate(lab.x, lab.y, lab.angle, x, y)
		end

		xadvance = c.xadvance * xscale
		f(x, y, w, h, c.texcoord)
	end
	return text_w, text_h
end

local function label_sprites_update_transform(lab, sprites, font)
	local i = 0
	local function update_transform(x, y, w, h, texcoord)
		i = i + 1
		local sp = sprites[i]
		sp.x = x
		sp.y = y
		sp.width = w
		sp.height = h
		sp.angle = lab.angle
		sp.update_transform()
	end
	return label_foreach_text(lab, font, update_transform)
end

local function label_create_text_sprites(lab, font)
	local i = 0
	local sprites = {}
	local function create_sprite(x, y, w, h, texcoord)
		i = i + 1
		sprites[i] = M.sprite{
			x = x,
			y = y,
			width = w,
			height = h,
			angle = lab.angle,
			color = lab.color,
			image = font.texture.name,
			texcoord = texcoord
		}
	end

	local text_width, text_height = label_foreach_text(lab, font, create_sprite)
	return sprites, text_width, text_height
end

function M.label(lab)
	local font = fontmgr.query(lab.font)
	local sprites

	lab.color = lab.color or 0xffffffff
	lab.angle = lab.angle or 0
	lab.size = lab.size or font.info.size
	lab.xalign = lab.xalign or "center"
	lab.yalign = lab.yalign or "center"

	sprites, lab.text_width, lab.text_height = label_create_text_sprites(lab, font)

	function lab.set_color(c)
		lab.color = c
		for _,sp in ipairs(sprites) do
			sp.set_color(c)
		end
	end

	function lab.set_text(text)
		lab.text = text
		sprites, lab.text_width, lab.text_height = label_create_text_sprites(lab, font)
	end

	function lab.update_transform()
		lab.text_width, lab.text_height = label_sprites_update_transform(lab, sprites, font)
	end

	function lab.draw()
		for _,sp in ipairs(sprites) do
			sp.draw()
		end
	end

	return lab
end


--
-- setter
--
local set = {}

function set.clearcolor(c)
	core.clearcolor = c
	core.set_clearcolor(c)
end


return setmetatable(M, {__index = core, __newindex = function (_, k, v)
	local f = assert(set[k], k)
	return f(v)
end}) 