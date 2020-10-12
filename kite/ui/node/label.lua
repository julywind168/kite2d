local gfx = require "kite.graphics"
local fontmgr = require "kite.manager.font"
local helper = require "kite.helper"

local transform_attr = {x=true, y=true, xscale=true, yscale=true, angle=true}

local BORDER_WIDTH = 2


local function get_text_width(font, text, xscale)
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

local function get_limit_text(text, n)
	local t = {}
	local c = 0
	for _, code in utf8.codes(text) do
		table.insert(t, utf8.char(code))
		c = c + 1
		if c == n then
			break
		end
	end
	return table.concat(t, "")
end

-- 第一个字符左上角的坐标
local function start_xy(x, y, text_width, text_height, xalign, yalign, size, yscale)
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

local function foreach_text(mt, text, font, xalign, yalign, size, f)
	local xscale = (size/font.info.size) * mt.world_xscale
	local yscale = (size/font.info.size) * mt.world_yscale
	local text_w = get_text_width(font, text, xscale)
	local text_h = font.common.lineHeight * yscale
	local x0, y0 = start_xy(mt.world_x, mt.world_y, text_w, text_h, xalign, yalign, size, yscale)

	local xadvance = 0
	local x, y, w, h

	for i,code in utf8.codes(text) do
		x0 = x0 + xadvance
		local c = assert(font.char[code])
		w = c.width * xscale
		h = c.height * yscale
		x = x0 + w / 2
		y = y0 - c.yoffset * yscale - h/2

		if mt.world_angle ~= 0 then
			x, y = helper.rotate(mt.world_x, mt.world_y, mt.world_angle, x, y)
		end

		xadvance = c.xadvance * xscale
		f(i, x, y, w, h, c.texcoord)
	end
end

local function sprites_update_transform(sprites, mt, text, font, xalign, yalign, size)
	local function update_transform(i, x, y, w, h, texcoord)
		local sp = sprites[i]
		sp.x = x
		sp.y = y
		sp.width = w
		sp.height = h
		sp.angle = mt.world_angle
		sp.update_transform()
	end
	foreach_text(mt, text, font, xalign, yalign, size, update_transform)
end

local function create_text_sprites(mt, text, font, xalign, yalign, size, color)
	local sprites = {}
	local function create_sprite(i, x, y, w, h, texcoord)
		sprites[i] = gfx.sprite{
			x = x,
			y = y,
			width = w,
			height = h,
			angle = mt.world_angle,
			color = color,
			image = font.texture.name,
			texcoord = texcoord
		}
	end

	foreach_text(mt, text, font, xalign, yalign, size, create_sprite)

	return sprites
end


return function (node, mt, proxy)
	node.color = node.color or 0xffffffff

	local font = fontmgr.query(node.font)
	local size = node.size or font.info.size
	local xalign = node.xalign or "center"
	local yalign = node.yalign or "center"
	local text = node.text
	local limit = node.limit

	mt.world_width = node.width * mt.world_xscale
	mt.world_height = node.height * mt.world_yscale

	local sprites = create_text_sprites(mt, text, font, xalign, yalign, size, node.color)

	function mt.draw()
		for _,sp in ipairs(sprites) do
			sp.draw()
		end
	end

	function mt.update_transform()
		sprites_update_transform(sprites, mt, text, font, xalign, yalign, size)
	end

	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if k == "color" then
			assert(type(v) == "number" and v >= 0)
			node.color = v
			for _,sp in ipairs(sprites) do
				sp.set_color(v)
			end
		elseif k == "text" then
			text = v
			if limit and utf8.len(v) > limit then
				text = get_limit_text(v, text)
			end
			node.text = text
			
			sprites = create_text_sprites(mt, text, font, xalign, yalign, size, node.color)
		elseif node[k] then
			if transform_attr[k] then
				mt.modify[k] = v
			else
				error(k.." is read-only")
			end
		else
			rawset(proxy, k, v)
		end
	end})
end