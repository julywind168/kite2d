----------------------------------------------------------------------------------------
--
-- 在 ecs02 的例子中我们将 完成如下功能
-- 1. 地图层, 精灵层 (主角, 怪物, 树木), UI层, 分层渲染, 其中精灵层要根据Y值进行排序(Y越大 越先渲染) see systems/Render.lua
-- 2. 帧动画的实现 flipbook
----------------------------------------------------------------------------------------
package.path = 'examples/ecs02/?.lua;examples/ecs02/?/init.lua;' .. package.path

local kite = require 'kite'
local gfx = require 'kite.graphics'
local ecs = require 'ecs'
local create = require 'ecs.functions'

local Render = require 'ecs.systems.Render'
local Animation = require 'ecs.systems.Animation'


-- start
local background = create.sprite{ texname='examples/assert/bg.jpg', x=480, y=320 } + TAG('TAG_MAP_LAYER')
local helloworld = create.label{ text='Hello World', x=480, y=320, fontsize=48, color=0xff0000ff } + TAG('TAG_UI_LAYER') 

local bird = create.flipbook{
		x=480, y=420,
		w=48, h=48,
		isloop=true, current=1, speed=1,
		frames = {
			{texname='examples/assert/bird0_0.png'},
			{texname='examples/assert/bird0_1.png'},
			{texname='examples/assert/bird0_2.png'},
		}} + TAG('TAG_SPRITE_LAYER')


local world = ecs.world()
	.add_system(Animation())
	.add_system(Render())
	.add_entity(background)
	.add_entity(bird)
	.add_entity(helloworld)


local game = {}

function game.update(dt)
	world('update', dt) 	-- dispatch event 'update'
end

function game.draw()
	world('draw') 			-- dispatch event 'draw'
end

function game.mouse(what, x, y, who)
end

function game.keyboard(key, what)
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