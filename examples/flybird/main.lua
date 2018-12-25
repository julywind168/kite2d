----------------------------------------------------------------------------------------
--
-- 第二个 demo, 打算做个flybird, 现在只能飞, 开始后 可以按 up 键 使小鸟向上飞
--
----------------------------------------------------------------------------------------

package.path = 'examples/?.lua;examples/?/init.lua;' .. package.path

local kite = require 'kite'
local Miss = require 'kite.Miss'
local ecs = require 'ecs'
local Render = require 'ecs.systems.Render'
local Input = require 'ecs.systems.Input'
local Moving = require 'ecs.systems.Moving'
local Gravity = require 'ecs.systems.Gravity'
local Animation = require 'ecs.systems.Animation'
local Debug = require 'ecs.systems.Debug'

local create = require 'ecs.functions'

local entities = require 'editor.out.flybird_entities_v1'

local function in_e(x, y, e)
	local w = e.w * e.sx
	local h = e.h * e.sy
	local x2 = e.x - e.ax * w
	local y2 = e.y - e.ay * h

	if x < x2 or x > x2 + w then return false end
	if y < y2 or y > y2 + h then return false end
	return true
end

local function rect_carsh(e0, e)
	local w = e.w * e.sx
	local h = e.h * e.sy
	local x2 = e.x - e.ax * w
	local y2 = e.y - e.ay * h
	return in_e(x2, y2, e0) or in_e(x2+w, y2, e0) or in_e(x2, y2+h, e0) or in_e(x2+w, y2+h, e0)
end

local function bird_carsh(bird, pipes)
	if bird.y - bird.h/2 + 8 < 138 then return true end

	for i,pipe in ipairs(pipes) do
		if rect_carsh(pipe, bird) then
			print('pipe'..i, pipe.x, pipe.y)
			return true
		end
	end
end


local world = ecs.world(entities)
local game_layer = entities.list[2]
local button = world.find_entity('play')
local textfield = world.find_entity('textfield')
local score = world.find_entity('score')
local bird = world.find_entity('bird')
local bird_nick = bird.list[1]

-- 小鸟的实际大小 (碰撞检测需要)
bird.w = 30
bird.h = 24

local pipes = {}
for i=21,40 do
	table.insert(pipes, game_layer.list[i])
end

local g = Miss { nick = '请修改我', score = 'Score:0', state = 'ready', timec = 0, speed = 160 }
		.miss('nick', textfield.label, 'text', bird_nick, 'text')
		.miss('score', score, 'text')


local handle = { }

function handle.click(name)
	if name ~= 'play' then return end
	
	if g.state == 'over' then
		g.timec = 0
		g.score = 'Score:0'
		bird.x = 480
		bird.y = 320
		bird.rotate = 0
		bird.direction = 0
	end

	g.state = 'gameing'
	button.active = false
	textfield.active = false
	bird.speed = g.speed
	bird.mass = 1
end

function handle.keydown(key)
	if key ~= 'up' then return end
	if g.state ~= 'gameing' then return end
	
	bird.speed = math.sqrt(g.speed^2 + g.speed^2)
	bird.direction = 45
	bird.rotate = 45
end

function handle.update(dt)

	bird_nick.rotate = - bird.rotate	
	game_layer.x = 480-bird.x

	if g.state == 'gameing' then
		g.timec = g.timec + dt

		g.score = 'Score:' .. math.floor(g.timec)

		if bird_carsh(bird, pipes) then
			print('game over, you dead ...')
			g.state = 'over'
			bird.mass = 0
			bird.speed = 0
			button.active = true
		end
	end
	-- update miss
	g()
end

world = world
	.set_handle(handle)
	.add_system(Input())
	.add_system(Gravity())
	.add_system(Moving())
	.add_system(Animation())
	.add_system(Render())
	.add_system(Debug())


kite.start(world.cb)