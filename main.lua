local fantasy = require "fantasy"
local ecs = require "ecs"
local render_system = require "ecs.systems.Render"
local Node = require "ecs.components.Node"
local Sprite = require "ecs.components.Sprite"

local world

local game = {}

function game.init()

	world = ecs.world('game')

	local bg = ecs.entity()
	bg('add', Node, {x=480, y=320, width=960, height=640})
	bg('add', Sprite, {texture='examples/asset/bg.jpg'})

	local tree = {bg}

	world.add_system(render_system(tree))
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