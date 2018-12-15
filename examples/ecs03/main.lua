----------------------------------------------------------------------------------------
--
-- 在 ecs03 中 我们要实现
-- 1. button 并响应点击事件, 思路就是加一个Input系统用来处理 点击 按键 文字输入 事件,
-- 		为了实现点击(或按键)后的逻辑，我们要传一个 handle(s) 给 Input系统 回调
-- 2. 输入框(TextField)的实现
-- 		重构之前已经做过了, 主要是先画一个背景, 再画一个裁剪框, 再画 label, 再加一个闪烁的光标
-- 
----------------------------------------------------------------------------------------
package.path = 'examples/ecs03/?.lua;examples/ecs03/?/init.lua;' .. package.path

local kite = require 'kite'
local gfx = require 'kite.graphics'
local ecs = require 'ecs'
local create = require 'ecs.functions'

local Render = require 'ecs.systems.Render'
local Animation = require 'ecs.systems.Animation'
local Moveing = require 'ecs.systems.Moveing'
local Input = require 'ecs.systems.Input'

--[[
	这里 这么写的原因是为了 模拟 从文件中加载 entities, 比如我们的 entities 可以用编辑器生产 
]]
local function load_entities()
	return {
		ecs.entity('game', {gameing = false}),
		create.sprite{ texname='examples/assert/bg.jpg', x=480, y=320 } + TAG('TAG_MAP_LAYER'),
		create.label{ text='Hello World', x=480, y=320, fontsize=48, color=0xff0000ff } + TAG('TAG_UI_LAYER'),
		create.button({ texname='examples/assert/button_ok.png', x=480, y=220 }, 'start') + TAG('TAG_UI_LAYER'),
		create.flipbook({ x=480, y=420, isloop=true, pause = true, frames = {
					{texname='examples/assert/bird0_0.png'},
					{texname='examples/assert/bird0_1.png'},
					{texname='examples/assert/bird0_2.png'}
				}}, 'bird') + TAG('TAG_SPRITE_LAYER') + Move(0, 0),
	}
end


local world = ecs.world().add_entitys(load_entities())

local game = world.find_entity('game')
local bird = world.find_entity('bird')
local start = world.find_entity('start')


local handle = { click = {}, keydown = {} }

-- start button click handle
function handle.click.start()
	game.gameing = true
	start.active = false
	bird.pause = false

	-- listen left/right keydown on start 
	function handle.keydown.left()
		bird.fx = true 		-- flip x 将小鸟水平镜像
		bird.speed = -100 	-- 方向是0度 (向右), 负数刚好是向左 (bird.direction = 180 效果一样)
	end

	function handle.keydown.right()
		bird.fx = false
		bird.speed = 100
	end
end

world.add_system(Render())
	.add_system(Animation())
	.add_system(Moveing())
	.add_system(Input(handle))


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
end

function game.resume()
end

function game.pause()
end

function game.exit()
	print('see you next version, current is v'..kite.version())
end

kite.start(game)