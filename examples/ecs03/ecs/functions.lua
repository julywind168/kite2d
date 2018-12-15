local gfx = require "kite.graphics"
local ecs = require "ecs"

require "ecs.components"

local M = {}


function M.flipbook(t, name)
	local frames = t.frames
	for _,frame in ipairs(frames) do
		frame.texcoord = frame.texcoord or {0,1, 0,0, 1,0, 1,1}
		local tex = gfx.texture(frame.texname)
		frame.w = frame.w or tex.w
		frame.h = frame.h or tex.h
		frame.ox = frame.ox or 0
		frame.oy = frame.oy or 0
		frame.fx = frame.fx or false
		frame.fy = frame.fy or false
	end

	local e = ecs.entity(name)
			+ Node(t.active ~= false and true or false, 'flipbook')
			+ Position(t.x, t.y)
			+ Transform(t.sx, t.sy, t.rotate)
			+ Rectangle(t.w or 0, t.h or 0, t.ax, t.ay)
			+ Flipbook(t.frames, t.current, t.pause, t.isloop, t.speed, t.timec, t.fx, t.fy)
	return e
end


function M.button(t, name)
	local e = M.sprite(t, name)
		+ Button(t.scale or 1.2)
	return e
end


function M.sprite(t, name)

	assert(t and t.x and t.y)
	local tex = gfx.texture(t.texname)
	
	local e = ecs.entity(name)
			+ Node(t.active ~= false and true or false, 'sprite')
			+ Position(t.x, t.y)
			+ Transform(t.sx, t.sy, t.rotate)
			+ Sprite(t.texname, t.texcoord, t.color)
			+ Rectangle(t.w or tex.w, t.h or tex.h, t.ax, t.ay)

	return e
end

function M.label(t, name)

	assert(t and t.text and t.x and t.y)
	t.fontsize = t.fontsize or 24
			
	local w = 0 	-- width will init on draw
	local h = t.fontsize + 2 

	local e = ecs.entity(name)
			+ Node(t.active ~= false and true or false, 'label')
			+ Position(t.x, t.y)
			+ Transform(t.sx, t.sy, t.rotate)
			+ Label(t.text, t.fontsize, t.color)
			+ Rectangle(w, h, t.ax, t.ay)

	return e
end


return M