local gfx = require "kite.graphics"
local sprite2d = require "sprite2d.core"
local texmgr = require "kite.manager.texture"
local fontmgr = require "kite.manager.font"
local program = (require "kite.manager.program").get_sprite_program()
local sin = math.sin
local cos = math.cos

local M = {}

local function create_fill_rect(t)
	local x = t.x
	local y = t.y
	local w = t.w
	local h = t.h
	local color = t.color or 0xffffffff
	local tex = texmgr.get('resource/white.png')
	local sp = sprite2d.create(tex.id, x, y, x, y-h, x+w, y-h, x+w, y, 0,1, 0,0, 1,0, 1,1)
	local self = {}

	function self.set_color(c)
		color = c
	end

	function self.draw()
		program.set_color(color)
		gfx.draw(sp)
	end

	function self.pos(x1, y1)
		if x1 == x and y1 == y then return end
		x = x1
		y = y1
		sprite2d.set_position(sp, x, y, x, y-h, x+w, y-h, x+w, y)
	end

	return self
end

-- in-side line rect
local function create_line_rect(t)
	local x = t.x
	local y = t.y
	local w = t.w
	local h = t.h
	local color = t.color or 0xffffffff
	local size = t.size or 1

	local top 		= create_fill_rect{ x=x,        y=y,          w=w,    h=size,     color=color }
	local bottom 	= create_fill_rect{ x=x,        y=y-h+size*2, w=w,    h=size,     color=color }
	local left 		= create_fill_rect{ x=x,        y=y-size,     w=size, h=h-size*2, color=color }
	local right 	= create_fill_rect{ x=x+w-size, y=y,          w=size, h=h-size*2, color=color }

	local self = {}

	function self.set_color(c)
		top.set_color(c)
		left.set_color(c)
		bottom.set_color(c)
		right.set_color(c)
	end

	function self.draw()
		top.draw()
		left.draw()
		bottom.draw()
		right.draw()
	end

	return self
end


function M.rectangle(type, t)
	if type == 'fill' then
		return create_fill_rect(t)
	else
		assert(type == 'line')
		return create_line_rect(t)
	end
end


local function get_text_width(font, text, size)
	local x = 0
	local w = 0
	local xadvance = 0
	local scale = size/font.info.size
	local last_w

	for _,id in utf8.codes(text) do
		local c = assert(font.char[id])
		x = x + xadvance
		last_w = c.width
		xadvance = c.xadvance*scale 
	end

	return math.floor(x + 2 + last_w * scale)
end


function M.text(t)
	local font = fontmgr.get(t.font)
	local size = t.size or font.info.size
	local scale = size/font.info.size
	local align = t.align or 'left'
	local x = t.x
	local y = t.y - math.floor(scale) + size//2 -- y center
	local text = t.text
	local color = t.color or 0xffffffff

	local w = get_text_width(font, text, size)

	if align == 'center' then
		x = x - w//2
	elseif align == 'right' then
		x = x - w
	end

	local border = t.border
	local border_color = border and border.color or 0xffffffff
	local border_sprites = {}

	local _sprites = {}
	local sprites = {}

	local x1 = x + 1 -- 1px border
	local xadvance = 0
	local y1, x3, y3

	for _,id in utf8.codes(text) do
		local c = assert(font.char[id])
		x1 = x1 + xadvance
		y1 = y - c.yoffset * scale 
		x3 = x1 + c.width * scale
		y3 = y1 - c.height * scale

		local sp = sprite2d.create(
				program.id,
				font.texture.id,
				color,
				x1, y1, 
				x1, y3,
				x3, y3, 
				x3, y1,
				table.unpack(c.texcoord)
			)

		if border then
			local bz = border.size
			table.insert(border_sprites, sprite2d.create(program.id, font.texture.id, border_color, x1-bz, y1, x1-bz, y3, x3-bz, y3, x3-bz, y1, table.unpack(c.texcoord)))
			table.insert(border_sprites, sprite2d.create(program.id, font.texture.id, border_color, x1+bz, y1, x1+bz, y3, x3+bz, y3, x3+bz, y1, table.unpack(c.texcoord)))
			table.insert(border_sprites, sprite2d.create(program.id, font.texture.id, border_color, x1, y1-bz, x1, y3-bz, x3, y3-bz, x3, y1-bz, table.unpack(c.texcoord)))
			table.insert(border_sprites, sprite2d.create(program.id, font.texture.id, border_color, x1, y1+bz, x1, y3+bz, x3, y3+bz, x3, y1+bz, table.unpack(c.texcoord)))
		end

		xadvance = c.xadvance*scale 

		_sprites[id] = sp
		table.insert(sprites, sp)
	end

	local self = {
		x = x,
		y = y,
		w = w,
		h = size,
		border = border
	}

	function self.set_text(new_text)
	end

	function self.draw()
		if border then
			for _,sp in ipairs(border_sprites) do
				gfx.draw(sp)
			end
		end
		for _,sp in ipairs(sprites) do
			gfx.draw(sp)
		end
	end

	return self
end

function M.button(t)
	local x = t.x
	local y = t.y
	local w = t.w
	local h = t.h
	local color = t.color or {}

	local background = create_fill_rect{x=x, y=y, w=w, h=h, color=0xffffffff}
	local border = create_line_rect{x=x, y=y, w=w, h=h, color=0xc8c8c8ff}
	local text = M.text{x=x+w/2, y=y-h/2, align='center', text=t.text, color=0x868686ff, font='generic'}

	local self = {
		x = x,
		y = y,
		w = w,
		h = h
	}

	function self.draw()
		background.draw()
		border.draw()
		text.draw()
	end

	local on = {}

	function on.mouse_enter()
		background.set_color(0xbcecffff)
	end

	function on.mouse_leave()
		background.set_color(0xffffffff)
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = on[event]
		if f then
			f(...)
		end
	end})
end



return M