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
local HeroCamera = require "ecs.s-components.HeroCamera"

local util = require "ecs.util.sprite"

local font = {
	arial = "examples/asset/font/arial.ttf",
	msyh = "C:/Windows/Fonts/msyh.ttc"
}


local CFA = util.coord_from_atlas

local function Hero(world, x, y, skill)

	local hero
	local walk_down, walk_left, walk_right, walk_up
	walk_down = ecs.entity('walk_down')
		+ Node{}
		+ Trans{x=x,y=y}
		+ Flipbook {
			frames = {
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,1)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,1)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,1)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,1)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,1)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,1)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,2)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,2)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,2)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,2)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,2)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,2)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,3)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,3)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,3)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,3)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,3)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,3)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,4)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,4)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,4)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,4)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,4)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,4)},
				}
			},
			interval = 0.2,
			isloop = true,
			pause = true,
		}
	walk_left = ecs.entity('walk_left')
		+ Node{}
		+ Trans{x=x,y=y}
		+ Flipbook {
			frames = {
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,5)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,5)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,5)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,5)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,5)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,5)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,6)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,6)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,6)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,6)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,6)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,6)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,7)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,7)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,7)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,7)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,7)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,7)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,8)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,8)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,8)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,8)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,8)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,8)},
				}
			},
			interval = 0.2,
			isloop = true,
			pause = true,
		}
	walk_right = ecs.entity('walk_right')
		+ Node{}
		+ Trans{x=x,y=y}
		+ Flipbook {
			frames = {
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,9)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,9)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,9)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,9)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,9)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,9)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,10)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,10)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,10)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,10)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,10)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,10)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,11)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,11)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,11)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,11)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,11)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,11)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,12)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,12)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,12)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,12)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,12)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,12)},
				}
			},
			interval = 0.2,
			isloop = true,
			pause = true,
		}
	walk_up = ecs.entity('walk_up')
		+ Node{}
		+ Trans{x=x,y=y}
		+ Flipbook {
			frames = {
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,13)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,13)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,13)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,13)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,13)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,13)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,14)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,14)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,14)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,14)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,14)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,14)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,15)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,15)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,15)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,15)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,15)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,15)},
				},
				ecs.entity()+Node()+Trans{x=x,y=y}+Group{
					ecs.entity()+Node{}+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/body.png', texcoord=CFA(4,4,16)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/arms.png', texcoord=CFA(4,4,16)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/eyes.png', texcoord=CFA(4,4,16)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/hair.png', texcoord=CFA(4,4,16)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/shoes.png', texcoord=CFA(4,4,16)},
					ecs.entity()+Node()+Trans{x=x,y=y}+Sprite{texname='examples/asset/avatar/clothes.png', texcoord=CFA(4,4,16)},
				}
			},
			interval = 0.2,
			isloop = true,
			pause = true,
		}

	hero = world.add_entity(ecs.entity()
		+ Node{}
		+ Trans{x=x,y=y}
		+ Speed{}
		+ Animation {walk_down, walk_left, walk_right, walk_up}
		+ HeroCamera{screen={0,0, 1280,1280}, limit={w=200,h=200}})

	hero.on('keydown', function (key)

		if key == 'a' then
			if hero.direction == 90 then
				skill.x = hero.x
				skill.y = hero.y
			elseif hero.direction == 0 then
				skill.x = hero.x + 150
				skill.y = hero.y - 140
			elseif hero.direction == 180 then
				skill.x = hero.x - 150
				skill.y = hero.y - 140
			elseif hero.direction == 270 then
				skill.x = hero.x
				skill.y = hero.y - 270
			end
			skill.active = true
			skill.pause = false
		end

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
local skill

local game = {init = function()

	world = ecs.world().add_system(Input).add_system(Render).add_system(Script).add_system(Move)

	world.add_entity(ecs.entity('background') + Node{} + Trans{x=640,y=640} + Sprite{texname='examples/asset/map/arkanos.png'})

	skill = world.add_entity(ecs.entity()
		+ Node{active=false}
		+ Trans{}
		+ Flipbook{
			frames = {
				ecs.entity()+Node{}+Trans{}+Sprite{texname='examples/asset/skill/s1.png', ay=0},
				ecs.entity()+Node()+Trans{}+Sprite{texname='examples/asset/skill/s2.png', ay=0},
				ecs.entity()+Node()+Trans{}+Sprite{texname='examples/asset/skill/s3.png', ay=0},
				ecs.entity()+Node()+Trans{}+Sprite{texname='examples/asset/skill/s4.png', ay=0},
				ecs.entity()+Node()+Trans{}+Sprite{texname='examples/asset/skill/s5.png', ay=0},
				ecs.entity()+Node()+Trans{}+Sprite{texname='examples/asset/skill/s6.png', ay=0},
				ecs.entity()+Node()+Trans{}+Sprite{texname='examples/asset/skill/s7.png', ay=0},
			},
			interval = 0.16,
			isloop = false,
			pause = true,
		})

	skill.on('action_done', function ()
		skill.active = false
		skill.pause = true
		skill.cur_frame = 1
	end)

	hero = Hero(world, 256, 100, skill)


-- 菜单背景
	world.add_entity(ecs.entity()
		+ Node{camera=false}
		+ Trans{x=480,y=640}
		+ Sprite{w=960,h=44, color=0x00000077, ay=1})

	world.add_entity(ecs.entity()
		+ Node{camera=false}
		+ Trans{x=20,y=630}
		+ Rect{ax=0,ay=1}
		+ Label{text='fps:60',color=0xffffffff, fontname=font.arial, fontsize=24}
		+ Fps())

	world.add_entity(ecs.entity()
		+ Node{camera=false}
		+ Trans{x=940,y=630}
		+ Rect{ax=1,ay=1}
		+ Label{text='按键a: 紫电狂龙',color=0xffff00ff, fontname=font.msyh, fontsize=24})

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