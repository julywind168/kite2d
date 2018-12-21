local gfx = require 'kite.graphics'
local ecs = require 'ecs'
require 'ecs.components'


local M = {}


function M.flipbook(t)
	local frames = t.frames
	for _,frame in ipairs(frames) do
		frame.texcoord = frame.texcoord or {0,1, 0,0, 1,0, 1,1}
		local tex = gfx.texture(frame.texname)
		frame.w = frame.w or tex.w
		frame.h = frame.h or tex.h
		frame.x = frame.x or 0
		frame.y = frame.y or 0
		frame.sx = frame.sx or 1
		frame.sy = frame.sy or 1
		frame.rotate = frame.rotate or 0
	end
	return ecs.entity(t.name) + Flipbook(t)
end


function M.textfield(t)
	assert(t.background and t.background.color and t.label)

	t.label.x = 0
	t.label.y = 0
	t.label.ay = t.ay or 0.5
	t.background.texname = t.background.texname or 'resource/white.png'
	t.background.texcoord = t.background.texcoord or {0,1, 0,0, 1,0, 1,1}
	t.mask = t.mask or {texname = 'resource/null.png', texcoord = {0,1, 0,0, 1,0, 1,1}, color = 0xffffffff}
	t.cursor = t.cursor or {texname = 'resource/white.png', texcoord = {0,1, 0,0, 1,0, 1,1}, color = 0xffffffff, x=0, y=0}

	return ecs.entity(t.name) + Textfield(t)
end


function M.camera(t)
	t = t or {}
	return ecs.entity(t.name) + Camera(t)
end


function M.label(t)
	return ecs.entity(t.name) + Label(t)
end

function M.button(t)
	local tex = gfx.texture(t.texname)
	t.w = t.w or tex.w
	t.h = t.h or tex.h
	return ecs.entity(t.name) + Button(t)
end

function M.sprite(t)
	t.texname = t.texname or 'resource/white.png'
	local tex = gfx.texture(t.texname)
	t.w = t.w or tex.w
	t.h = t.h or tex.h
	return ecs.entity(t.name) + Sprite(t)
end

function M.keyboard()
	return ecs.entity('keyboard') + Keyboard()
end

function M.mouse()
	return ecs.entity('mouse') + Mouse()
end

function M.canvas(name)
	local t = {}

	local canvas = ecs.entity(name)
		+ Node(t)
		+ Transform(t)
		+ Group(t)
	return canvas
end

M.layer = M.canvas


return M