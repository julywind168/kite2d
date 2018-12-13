local gfx = require "kite.graphics"
local ecs = require "ecs"

require "ecs.components"

local M = {}


function M.sprite(t, name)

	assert(t and t.tex and t.x and t.y)
	local w, h = gfx.texture_size(t.tex)
	
	local e = ecs.entity(name)
			+ Node(t.active ~= false and true or false)
			+ Position(t.x, t.y)
			+ Transform(t.sx, t.sy, t.rotate)
			+ Sprite(t.tex, t.color)
			+ Rectangle(t.w or w, t.h or h, t.ax, t.ay)

	return e
end

function M.label(t, name)

	assert(t and t.text and t.x and t.y)
	t.fontsize = t.fontsize or 24
			
	local w = 0 	-- width will init on draw
	local h = t.fontsize + 2 

	local e = ecs.entity(name)
			+ Node(t.active ~= false and true or false)
			+ Position(t.x, t.y)
			+ Transform(t.sx, t.sy, t.rotate)
			+ Label(t.text, t.fontsize, t.color)
			+ Rectangle(w, h, t.ax, t.ay)

	return e
end


return M