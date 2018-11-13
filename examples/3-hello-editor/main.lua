local fantasy = require "fantasy"
local graphics = require "fantasy.graphics"

local ecs = require "ecs"
local render_system = require "ecs.systems.Render"
local move_system = require "ecs.systems.Move"
local animation_system = require "ecs.systems.Animation"
local input_system = require "ecs.systems.Input"

local Sprite = require "ecs.components.Sprite"
local Speed = require "ecs.components.Speed"
local Animation = require 'ecs.components.Animation'
local Button = require "ecs.components.Button"


local world


local game = {}


function game.init()

	world = ecs.world('game')
	world.add_system(render_system)
	world.add_system(move_system)
	world.add_system(animation_system)
	world.add_system(input_system)
	-- background
	world.add_entity(ecs.entity()
		.add(Sprite {x=480,y=320,width=960,height=640,texname='examples/asset/bg.jpg'}))

	-- bird
	local bird0 = Sprite {x=48,y=320,width=96,height=96,texname='examples/asset/bird0_0.png'}
	local bird1 = Sprite {x=48,y=320,width=96,height=96,texname='examples/asset/bird0_1.png'}
	local bird2 = Sprite {x=48,y=320,width=96,height=96,texname='examples/asset/bird0_2.png'}
	
	local bird = world.add_entity(ecs.entity()
		.add(bird0).add(bird1).add(bird2)
		.add(Animation {frames={bird0, bird1, bird2},isloop=true,interval=0.08,pause=true})
		.add(Speed {x=0, y=0}))


	-- color block
	world.add_entity(ecs.entity()
		.add(Sprite {x=480,y=320,width=200,height=200,color=0xff00ffff}))

	-- button
	local btn_sp = Sprite {x=480,y=200,width=80,height=28,texname='examples/asset/button_ok.png', camera = false}
	local ok = world.add_entity(ecs.entity()
		.add(btn_sp)
		.add(Button {sprite = btn_sp, scale = 1.1}))

	ok.find('button').on('click', function ()
		bird.find('speed').x = 100
		bird.find('animation').pause = false
	end)
end


function game.update(dt)
	-- print('fps:', 1//dt)
	world('update', dt)
end


function game.draw()
	world('draw')
end


function game.mouse(what, x, y, who) -- 'press'/'release/move' 0, 0, 'left'/'right'(on windows)
	world('mouse', what, x, y, who)
end


function game.keyboard(key, what)	-- 'a', 'press'/'release'
	print(key, what)
	if what == 'release' and key == 'a' then
		print('cccccccccccccccccc')
		graphics.set_color(math.random(0x11111111, 0xffffffff))
	end
end


function game.resume()
end

function game.pause()
end

function game.exit()
end


local config = {
	window = {
		width = 960,
		height = 640,
		title = 'Fantasy Editor'
	},
	camera = {
		x = 480,
		y = 320
	}
}

fantasy.start(config, game)