local fantasy = require "fantasy"
local graphics = require "fantasy.graphics"

local ecs = require "ecs"
local render_system = require "ecs.systems.Render"
local move_system = require "ecs.systems.Move"
local animation_system = require "ecs.systems.Animation"

local Sprite = require "ecs.components.Sprite"
local Speed = require "ecs.components.Speed"
local Animation = require 'ecs.components.Animation'


local world
local bird


local game = {}


function game.init()

	world = ecs.world('game')
	world.add_system(render_system)
	world.add_system(move_system)
	world.add_system(animation_system)

	world.add_entity(ecs.entity()
		.add(Sprite {x=480,y=320,width=960,height=640,texname='examples/asset/bg.jpg'}))

	math.randomseed(os.time())

	for i=1,10 do
		world.add_entity(ecs.entity()
			.add(Sprite {x=480,y=320,width=100,height=100,texname='examples/asset/smlie.jpg'})
			.add(Speed {x=math.random(-100, 100)*5, y=math.random(-100, 100)*5}))
	end

	
	local bird0 = Sprite {x=48,y=320,width=96,height=96,texname='examples/asset/bird0_0.png'}
	local bird1 = Sprite {x=48,y=320,width=96,height=96,texname='examples/asset/bird0_1.png'}
	local bird2 = Sprite {x=48,y=320,width=96,height=96,texname='examples/asset/bird0_2.png'}
	
	local bird = ecs.entity()
		.add(bird0).add(bird1).add(bird2)
		.add(Animation {frames={bird0, bird1, bird2},isloop=true,interval=0.08,pause = false})
		.add(Speed {x=100})

	world.add_entity(bird)
end


function game.update(dt)
	-- print('fps:', 1//dt)
	world('update', dt)
end


function game.draw()
	world('draw')
end


function game.mouse(what, x, y, who) -- 'PRESS'/'RELEASE/MOVE' 0, 0, 'LEFT'/'RIGHT'(on windows)
	if what == 'MOVE' then return end
	print(x, y)
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