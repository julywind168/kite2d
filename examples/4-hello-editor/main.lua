local ft = require "fantasy"
local ecs = require "ecs"
local Render = require "ecs.systems.Render"
local Input = require "ecs.systems.Input"
local Script = require "ecs.systems.Script"
local Edit = require "ecs.systems.Edit"

local Trans = require "ecs.d-components.Transform"
local Rect = require "ecs.d-components.Rectangle"
local Label = require "ecs.s-components.Label"


local font = {
	arial = "examples/asset/font/arial.ttf",
	msyh = "C:/Windows/Fonts/msyh.ttc"
}

-- 要编辑的ui列表
local entities = require "examples.asset.entities"
local outfile = 'examples/asset/entities.lua'


local world

local game = {init = function()

	world = ecs.world()
		.add_system(Edit, outfile)	-- see here
		.add_system(Input)
		.add_system(Render)
		.add_system(Script)


	for _,e in ipairs(entities) do
		world.add_entity(e)
	end
	
	world.add_entity(ecs.entity('__tip__')
		+ Trans{x=950,y=630}
		+ Rect{ax=1, ay=1}
		+ Label{text='(x, y)',color=0xff0000ff, fontname=font.arial, fontsize=24, camera=false})

	world('init')
end}


function game.update(dt)
	world('update', dt)
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
		title = 'Hello Editor',
		fullscreen = false
	},
	camera = {
		x = 480,
		y = 320,
		scale = 1,
	}
}


ft.start(config, game)