local core = require 'graphics.core'
local sprite2d = require "sprite2d.core"
local texmgr = require "kite.manager.texture"
local program = (require "kite.manager.program").get_sprite_program()
local helper = require "kite.helper"


local M = {}


local function sprite_transform(sp)
	local w = sp.width
	local h = sp.height

	local x0 = sp.x
	local y0 = sp.y

	local x1 = x0 - w/2
	local y1 = y0 + h/2

	local x2 = x0 - w/2
	local y2 = y0 - h/2

	local x3 = x0 + w/2
	local y3 = y0 - h/2

	local x4 = x0 + w/2
	local y4 = y0 + h/2

	if sp.angle ~= 0 then
		x1, y1 = helper.rotate(x0, y0, sp.angle, x1, y1)
		x2, y2 = helper.rotate(x0, y0, sp.angle, x2, y2)
		x3, y3 = helper.rotate(x0, y0, sp.angle, x3, y3)
		x4, y4 = helper.rotate(x0, y0, sp.angle, x4, y4)
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



local set = {}

function set.clearcolor(c)
	core.clearcolor = c
	core.set_clearcolor(c)
end


return setmetatable(M, {__index = core, __newindex = function (_, k, v)
	local f = assert(set[k], k)
	return f(v)
end}) 