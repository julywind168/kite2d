local ft = require "fantasy"
local ecs = require "ecs"
local Render = require "ecs.systems.Render"
local Input = require "ecs.systems.Input"
local Script = require "ecs.systems.Script"

local Node = require "ecs.d-components.Node"
local Sprite = require "ecs.s-components.Sprite"
local Label = require "ecs.s-components.Label"
local Fps = require "ecs.s-components.Fps"
local Group = require "ecs.s-components.Group"
local TextField = require "ecs.s-components.TextField"

local font = {
	arial = "examples/asset/font/arial.ttf",
	msyh = "C:/Windows/Fonts/msyh.ttc"
}


local world

local game = {init = function()

	world = ecs.world()
		.add_system(Input)
		.add_system(Render, 0x666666ff)
		.add_system(Script)


	world.add_entity(ecs.entity()
		.add(Node, {x=480, y=320, width=960, height=640})
		.add_script(Sprite, {texname="examples/asset/bg.jpg"}))


	world.add_entity(ecs.entity()
		.add(Node, {x=20, y=620, anchor={x=0, y=1}})
		.add_script(Label, {font=font.arial, size=24, text='fps:60', color=0x554411ff})
		.add_script(Fps, 0.5))


	world.add_entity(ecs.entity()
		.add(Node, {x=480, y=320})
		.add_script(Label, {font=font.arial, size=48, text='Hello World!', color=0xff0000ff}))

	-- test group
	bird = world.add_entity(ecs.entity()
	.add_script(Group, {x=480, y=320,
	list = {
	world.add_entity(ecs.entity('background').add(Node,{x=480,y=250,width=200,height=48}).add_script(Sprite, {color = 0x223322ff})),
	world.add_entity(ecs.entity('mask').add(Node,{x=480,y=250,width=180,height=48}).add_script(Sprite, {texname = 'resource/null.png'})),
	world.add_entity(ecs.entity('label').add(Node,{x=480,y=244}).add_script(Label, {font=font.arial,text=''})),
	world.add_entity(ecs.entity('cursor').add(Node,{x=480,y=250,width=1,height=32,active=false}).add_script(Sprite, {color=0xffffffff}))
	}})
	.add_script(TextField))

	world('_init')
end}


function game.update(dt)
	world('_update', dt)
	-- bird.group.x = bird.group.x + 1
end


function game.draw()
	world('_draw')
end


function game.mouse(what, x, y, who)
	world('_mouse', what, x, y, who)
end

function game.keyboard(key, what)
	world('_keyboard', key, what)
end

function game.message(char)
	world('_message', char)
end

function game.resume()
end

function game.pause()
end

function game.exit()
end


local config = {
	window = {
		x = 1920/2,		-- screen pos
		y = 1080/2,		-- screen pos
		width = 960,
		height = 640,
		title = 'Hello World',
		fullscreen = false
	},
	camera = {
		x = 480,
		y = 320,
		scale = 1,
	}
}


ft.start(config, game)