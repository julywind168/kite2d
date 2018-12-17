----------------------------------------------------------------------------------------
--
-- 第二个 demo, 打算做个flybird, 现在只能飞
--
----------------------------------------------------------------------------------------
package.path = 'examples/flybird/?.lua;examples/flybird/?/init.lua;' .. package.path

local kite = require 'kite'
local gfx = require 'kite.graphics'
local ecs = require 'ecs'
local create = require 'ecs.functions'

local Render = require 'ecs.systems.Render'
local Animation = require 'ecs.systems.Animation'
local Moveing = require 'ecs.systems.Moveing'
local Input = require 'ecs.systems.Input'
local Gravity = require 'ecs.systems.Gravity'
local Debug = require 'ecs.systems.Debug'

--[[
	这里 这么写的原因是为了 模拟 从文件中加载 entities, 比如我们的 entities 可以用编辑器生产 
]]
local function load_entities()

	local entities = {}

	-- user define component
	table.insert(entities, ecs.entity('game', {land = 138, bird_x_speed = 180, state='ready'}))
	table.insert(entities, ecs.entity('camera', {x=0, y=0}))
	table.insert(entities, ecs.entity('keyboard', {pressed={}, lpressed={}}))

	for i=1,10 do
		table.insert(entities, create.sprite{ texname='examples/assert/bg_day.png', x=180 + (i-1)*360, y=320, w=360, h=640} + TAG('TAG_MAP_LAYER'))
	end

	for i=1,10 do
		table.insert(entities, create.sprite{ texname='examples/assert/land.png', x=180 + (i-1)*360, y=69, w=360, h=138} + TAG('TAG_MAP_LAYER'))
	end

	table.insert(entities, create.label({ text='Scroe:0', x=10, y=630, ax=0, ay=1, fontsize=24, color=0xff0000ff }, 'score') + TAG('TAG_UI_LAYER'))
	table.insert(entities, create.button({ texname='examples/assert/button_play.png', x=480, y=220 }, 'btn_play') + TAG('TAG_UI_LAYER'))
	local bird = create.flipbook({ x=480, y=420, isloop=true, pause = true, frames = {
					{texname='examples/assert/bird0_0.png'},
					{texname='examples/assert/bird0_1.png'},
					{texname='examples/assert/bird0_2.png'}
				}}, 'bird') + TAG('TAG_SPRITE_LAYER') + Move(0, 0)
	table.insert(entities, bird)


	local textfield = create.textfield({
			x = 480,
			y = 100,
			w = 200,
			h = 28,
			background = {color=0x333333ff},
			label = {color=0xff0000ff, fontsize=24, text = 'NICK'}
		}, 'nick') + TAG('TAG_UI_LAYER')
	table.insert(entities, textfield)


	return entities
end


local world = ecs.world().add_entitys(load_entities())


local game = world.find_entity('game')
local bird = world.find_entity('bird')
local btn_play = world.find_entity('btn_play')


local handle = { click = {}, keydown = {} }

-- start button click handle
function handle.click.btn_play()
	game.state = 'gameing'
	btn_play.active = false
	bird.pause = false
	bird.speed = game.bird_x_speed

	-- listen up keydown on start 
	function handle.keydown.up()
		bird.speed = math.sqrt(game.bird_x_speed^2 + game.bird_x_speed^2)
		bird.direction = 45
		bird.rotate = 45
	end
end


world.add_system(Animation())
	.add_system(Moveing())
	.add_system(Input(handle))
	.add_system(Debug())
	.add_system(Gravity())
	.add_system(Render())

local game = {}

function game.update(dt)
	world('update', dt) 	-- dispatch event 'update'
end

function game.draw()
	world('draw') 			-- dispatch event 'draw'
end

function game.mouse(what, x, y, who)
	if who == 'left' then
		if what == 'press' then
			world('mousedown', x, y)
		else
			world('mouseup', x, y)
		end
	elseif who == 'right' then
		if what == 'press' then
			world('rmousedown', x, y)
		else
			world('rmouseup', x, y)
		end
	else
		world('mousemove', x, y)
	end
end

function game.keyboard(key, what)
	if what == 'press' then
		world('keydown', key)
	else
		world('keyup', key)
	end
end

function game.message(char)
	world('message', char)
end

function game.resume()
end

function game.pause()
end

function game.exit()
	print('see you next version, current is v'..kite.version())
end

kite.start(game)