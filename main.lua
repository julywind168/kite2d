local fantasy = require "fantasy"
local graphics = require "fantasy.graphics"

local ecs = require "ecs"
local render_system = require "ecs.systems.Render"
local move_system = require "ecs.systems.Move"
local animation_system = require "ecs.systems.Animation"

local Node = require "ecs.components.Node"
local Sprite = require "ecs.components.Sprite"
local Speed = require "ecs.components.Speed"
local Animation = require 'ecs.components.Animation'


local world
local bird


local game = {}


function game.init()

	world = ecs.world('game')
	world.add_system(render_system())
	world.add_system(move_system())
	world.add_system(animation_system())

	world.join(ecs.entity({}, 'bg')
		('add',Node,{x=480,y=320,width=960,height=640})
		('add',Sprite,{texture='examples/asset/bg.jpg'}))

	for i=1,1 do
		world.join(ecs.entity({}, 'smlie')
			('add',Node,{x=480,y=320,width=100,height=100})
			('add',Sprite,{texture='examples/asset/smlie.jpg'})
			('add',Speed,{x=math.random(-100, 100), y=math.random(-100, 100)}))
	end


	local bird_frames = {
		graphics.texture('examples/asset/bird0_0.png'),
		graphics.texture('examples/asset/bird0_1.png'),
		graphics.texture('examples/asset/bird0_2.png'),
	}

	bird = world.join(ecs.entity({}, 'bird')
		('add',Node,{x=480,y=320,width=96,height=96})
		('add',Speed,{x=100,y=0})
		('add',Animation,{frames = bird_frames, isloop = true, interval=0.08}))	
end


function game.update(dt)
	-- print('fps:', 1//dt)
	world('update', dt)
end


function game.draw()
	world('draw')
end


function game.mouse(what, x, y, who) -- 'PRESS'/'RELEASE/MOVE' 0, 0, 'LEFT'/'RIGHT'(on windows)
end


function game.keyboard(key, what)	-- 'a', 'PRESS'/'RELEASE'
	if what == 'PRESS' then
		if key == 'left' then
			bird.speed.x = -100
		elseif key == 'right' then
			bird.speed.x = 100
		end
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
		title = 'Hello ECS'
	},
	camera = {
		x = 480,
		y = 320
	}
}

fantasy.start(config, game)