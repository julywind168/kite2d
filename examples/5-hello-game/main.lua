local ft = require "fantasy"
local ecs = require "ecs"
local Render = require "ecs.systems.Render"
local Input = require "ecs.systems.Input"
local Script = require "ecs.systems.Script"
local Move = require "ecs.systems.Move"

local Node = require "ecs.d-components.Node"
local Trans = require "ecs.d-components.Transform"
local Rect = require "ecs.d-components.Rectangle"
local Speed = require "ecs.d-components.Speed"

local Sprite = require "ecs.s-components.Sprite"
local Label = require "ecs.s-components.Label"
local Fps = require "ecs.s-components.Fps"
local Group = require "ecs.s-components.Group"
local Flipbook = require "ecs.s-components.Flipbook"
local Animation = require "ecs.s-components.Animation"

local util = require "ecs.util.sprite"

local font = {
	arial = "examples/asset/font/arial.ttf",
	msyh = "C:/Windows/Fonts/msyh.ttc"
}


local CFA = util.coord_from_atlas

local function Hero(world)

	local hero
	local walk_down, walk_left, walk_right, walk_up
	walk_down = ecs.entity('walk_down')
		+ Node{}
		+ Trans{x=480,y=320}
		+ Flipbook {
			frames = {
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,1)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,2)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,3)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,4)},
			},
			interval = 0.2,
			isloop = true,
			pause = true,
		}
	walk_left = ecs.entity('walk_left')
		+ Node{}
		+ Trans{x=480,y=320}
		+ Flipbook {
			frames = {
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,5)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,6)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,7)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,8)},
			},
			interval = 0.2,
			isloop = true,
			pause = true,
		}
	walk_right = ecs.entity('walk_right')
		+ Node{}
		+ Trans{x=480,y=320}
		+ Flipbook {
			frames = {
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,9)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,10)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,11)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,12)},
			},
			interval = 0.2,
			isloop = true,
			pause = true,
		}
	walk_up = ecs.entity('walk_up')
		+ Node{}
		+ Trans{x=480,y=320}
		+ Flipbook {
			frames = {
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,13)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,14)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,15)},
				ecs.entity()+Node{}+Trans{x=480, y=320}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,16)},
			},
			interval = 0.2,
			isloop = true,
			pause = true,
		}

	hero = world.add_entity(ecs.entity()
		+ Node{}
		+ Trans{x=480,y=320}
		+ Speed{}
		+ Animation {walk_down, walk_left, walk_right, walk_up})

	hero.on('keydown', function (key)
		if key == 'left' then
			hero.cur_action.cur_frame = 1
			hero.run_action('walk_left')
			hero.cur_action.pause = false
			hero.direction = 180
			hero.speed = 100
		elseif key == 'right' then
			hero.cur_action.cur_frame = 1
			hero.run_action('walk_right')
			hero.cur_action.pause = false
			hero.direction = 0
			hero.speed = 100
		elseif key == 'down' then
			hero.cur_action.cur_frame = 1
			hero.run_action('walk_down')
			hero.cur_action.pause = false
			hero.direction = 270
			hero.speed = 100
		elseif key == 'up' then
			hero.cur_action.cur_frame = 1
			hero.run_action('walk_up')
			hero.cur_action.pause = false
			hero.direction = 90
			hero.speed = 100
		end
	end)

	hero.on('keyup', function (key)
		if key == 'left' then
			hero.speed = 0
			hero.cur_action.pause = true
			hero.cur_action.cur_frame = 1
		elseif key == 'right' then
			hero.speed = 0
			hero.cur_action.pause = true
			hero.cur_action.cur_frame = 1
		elseif key == 'down' then
			hero.speed = 0
			hero.cur_action.pause = true
			hero.cur_action.cur_frame = 1
		elseif key == 'up' then
			hero.speed = 0
			hero.cur_action.pause = true
			hero.cur_action.cur_frame = 1
		end
	end)

	return hero
end

local world
local hero

local game = {init = function()

	world = ecs.world().add_system(Input).add_system(Render).add_system(Script).add_system(Move)

	world.add_entity(ecs.entity('background') + Node{} + Trans{x=640,y=640} + Sprite{texname='examples/asset/map/arkanos.png'})

	hero = Hero(world)

	world.add_entity(ecs.entity()
		+ Node{camera=false}
		+ Trans{x=20,y=620}
		+ Rect{ax=0,ay=1}
		+ Label{text='fps:60',color=0xffffffff, fontname=font.arial, fontsize=24}
		+ Fps())

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
		title = 'Hello Game',
		fullscreen = false
	},
	camera = {
		x = 480,
		y = 320,
		scale = 1,
	}
}


ft.start(config, game)