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


local function create_canvas()
	local canvas = create.canvas('canvas')
	local system_resource = ecs.entity() + Group()
	system_resource.list[1] = create.keyboard()
	system_resource.list[2] = create.mouse()
	
	local map_layer = create.layer()
	local game_layer = create.layer()
	local ui_layer = create.layer()
	local main_camera = create.camera{name = 'main_camera'}
	local ui_camera = create.camera()


	for i=1,10 do
		local map = create.sprite{ texname='examples/assert/bg_day.png', x=180+(i-1)*360, y=320, w=360, h=640 }
		table.insert(map_layer.list, map)
	end

	for i=1,10 do
		local map = create.sprite{ texname='examples/assert/land.png', x=180+(i-1)*360, y=69, w=360, h=138 }
		table.insert(map_layer.list, map)		
	end

	local button = create.button {name = 'play', texname = 'examples/assert/button_play.png', x=480, y=200 }
	local textfield = create.textfield {
		name = 'textfield',
		x = 480,
		y = 100,
		w = 200,
		h = 28,
		background = {color=0x333333aa},
		label = {color=0xffffffff, fontsize=24, text = 'NICK'}
	}

	local score = create.label {name='score', text='Score:0', x=10, y=630, ax=0, ay=1, color=0xaa3300ff }

	local bird = create.flipbook {
		name = 'bird',
		x = 480,
		y = 320,
		w = 48,
		h = 48,
		isloop = true,
		frames = {
			{texname='examples/assert/bird0_0.png'},
			{texname='examples/assert/bird0_1.png'},
			{texname='examples/assert/bird0_2.png'}
		}
	} + Move{speed = 0} + Mass{mass = 0} + Group{
		list = {create.label{text = 'NICK', x = 0, y = 34, fontsize = 20}}
	}


	game_layer.list[1] = bird

	ui_layer.list[1] = button
	ui_layer.list[2] = textfield
	ui_layer.list[3] = score

	
	canvas.list[1] = system_resource

	-- main camera
	canvas.list[2] = main_camera
	canvas.list[3] = map_layer
	canvas.list[4] = game_layer

	-- ui camera
	canvas.list[5] = ui_camera
	canvas.list[6] = ui_layer

	return canvas
end


local world = ecs.world(create_canvas())

local camera = world.find_entity('main_camera')
local button = world.find_entity('play')
local textfield = world.find_entity('textfield')
local score = world.find_entity('score')
local bird = world.find_entity('bird')
local bird_nick = bird.list[1]


local g = Miss { nick = '请修改我', score = 'Score:0', state = 'ready', timec = 0 }
		.miss('nick', textfield.label, 'text', bird_nick, 'text')
		.miss('score', score, 'text')


local handle = { click = {}, keydown = {} }

function handle.click.play()
	g.state = 'gameing'

	button.active = false
	textfield.active = false

	bird.speed = 200
	bird.mass = 1
end

function handle.keydown.up()
	if g.state ~= 'gameing' then return end
	bird.speed = math.sqrt(200^2 + 200^2)
	bird.direction = 45
	bird.rotate = 45
end

world.add_system(Input(handle))
	.add_system(Gravity())
	.add_system(Moving())
	.add_system(Animation())
	.add_system(Render())
	.add_system(Debug())



local function bird_carsh()
	if bird.y - bird.h/2 + 8 < 138 then return true end
end


local game = {}

function game.update(dt)
	world('update', dt)

	-- 我们并不想 nick 被旋转
	bird_nick.rotate = - bird.rotate
	
	-- 相机 跟随 bird
	camera.x = bird.x - 480


	-- logic
	if g.state == 'gameing' then
		g.timec = g.timec + dt

		g.score = 'Score:' .. math.floor(g.timec)

		if bird_carsh() then
			print('game over ...')
			g.state = 'over'
			bird.mass = 0
			bird.speed = 0
		end
	end

	-- update miss
	g()
end

function game.draw()
	world('draw')
end

function game.mouse(what, x, y, who)
	if who == 'left' then
		if what == 'press' then
			world('mousedown', x, y)
		else
			world('mouseup', x, y)
		end
	elseif who == 'right' then
		if what == 'press' then
			world('rmousedown', x, y)
		else
			world('rmouseup', x, y)
		end
	else
		world('mousemove', x, y)
	end
end

function game.keyboard(key, what)
	if what == 'press' then
		world('keydown', key)
	else
		world('keyup', key)
	end
end

function game.message(char)
	world('message', char)
end

function game.resume()
end

function game.pause()
end

function game.exit()
	print('see you next version, current is v'..kite.version())
end

kite.start(game)