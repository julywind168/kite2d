local ft = require "fantasy"
local ecs = require "ecs"
local Render = require "ecs.systems.Render"
local Input = require "ecs.systems.Input"
local Script = require "ecs.systems.Script"

local Node = require "ecs.d-components.Node"
local Trans = require "ecs.d-components.Transform"
local Rect = require "ecs.d-components.Rectangle"

local Sprite = require "ecs.s-components.Sprite"
local Label = require "ecs.s-components.Label"
local Button = require "ecs.s-components.Button"
local Struct = require "ecs.s-components.Struct"
local TextField = require "ecs.s-components.TextField"


local font = {
	arial = "examples/asset/font/arial.ttf",
	msyh = "C:/Windows/Fonts/msyh.ttc"
}


local world
local bg, fps, hw, ok, account

local game = {init = function()

	world = ecs.world()
		.add_system(Input)
		.add_system(Render)
		.add_system(Script)

	-- base
	bg = ecs.entity() + Node{active=true} + Trans{x=480,y=320} + Sprite{texname='examples/asset/bg.jpg'}
	fps = ecs.entity() + Node{active=true} + Trans{x=20,y=620} + Rect{ax=0, ay=1} + Label{text='fps:60',color=0x554411ff, fontname=font.arial, fontsize=24}
	hw = ecs.entity() + Node{active=true} +  Trans{x=480,y=320,angle=90} + Rect{} + Label{text='Hello World',color=0xff0000ff, fontname=font.arial, fontsize=48}
	
	world.add_entity(bg)
	world.add_entity(fps)
	world.add_entity(hw)


	-- text field
	account = world.add_entity(ecs.entity()
		+ Trans{x=480, y=200}
		+ Rect{w=200, h=40}
		+ Struct {
			ecs.entity('background') + Node{active=true} + Trans() + Sprite{color=0x333333aa},
			ecs.entity('mask') 		 + Node{active=true} + Trans() + Sprite{texname='resource/null.png'},
			ecs.entity('label') 	 + Node{active=true} + Trans() + Rect() + Label{text='hi...',color=0xffffffff, fontname=font.msyh, fontsize=24},
			ecs.entity('cursor') 	 + Node{active=true} + Trans() + Sprite{color=0xffffffff}
		}
		+ TextField())
	
	-- button
	ok = world.add_entity(ecs.entity() 
		+ Node{active=true}
		+ Trans{x=480,y=120}
		+ Sprite{texname='examples/asset/button_ok.png'}
		+ Button())

	ok.on('click', function ()
		printf('account: %s', account.label.text)
	end)

	world('init')
end}


function game.update(dt)
	world('update', dt)
	fps.text = 'fps:'..ft.fps	
end


function game.draw()
	world('draw')
end


function game.mouse(what, x, y, who)
	world('mouse', what, x, y, who)
end

function game.keyboard(key, what)
	world('keyboard', key, what)
end

function game.message(char)
	world('message', char)
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
		title = 'Hello ECS',
		fullscreen = false
	},
	camera = {
		x = 480,
		y = 320,
		scale = 1,
	}
}


ft.start(config, game)