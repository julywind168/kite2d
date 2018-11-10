local fantasy = require "fantasy"
local ecs = require "ecs"
local render_system = require "ecs.systems.Render"
local Node = require "ecs.components.Node"
local Sprite = require "ecs.components.Sprite"

local world

local game = {}

function game.init()

	world = ecs.world('game')
	world.add_system(render_system())

	world.join(ecs.entity()
		('add',Node,{x=480,y=320,width=960,height=640})
		('add',Sprite,{texture='examples/asset/bg.jpg'}))

	world.join(ecs.entity()
		('add',Node,{x=480,y=320,width=300,height=300})
		('add',Sprite,{texture='examples/asset/smlie.jpg'}))

end


function game.update(dt)
	world('update', dt)
end


function game.draw()
	world('draw')
end


function game.mouse(what, x, y, who) -- 'PRESS'/'RELEASE/MOVE' 0, 0, 'LEFT'/'RIGHT'(on windows)
end


function game.keyboard(key, what)	-- 'a', 'PRESS'/'RELEASE'
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