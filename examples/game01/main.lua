----------------------------------------------------------------------------------------
--
-- Game01 主要是让大家适应一下 kite-ECS
-- 接下来, 我们将以 ECS 为基础构建一套简单的 UI 系统
-- kite-ECS 参考了: https://github.com/ephja/love-ecs
--  
----------------------------------------------------------------------------------------
package.path = 'examples/game01/?.lua;examples/game01/?/init.lua;' .. package.path

local kite = require 'kite'
local gfx = require 'kite.graphics'
local ecs = require 'ecs'
local create = require 'ecs.functions'

local Render = require 'ecs.systems.Render'

--
-- 让我们手动构造一种 entity (纯数据的集合), 仅用于理解 
--
local function create_sprite(t, name)
	local e = {}
	e.name = name or 'unknown'
	e.has = {node={'active'},position={'x','y'},transform={'sx','sy','rotate'},sprite={'texture','color'},rectangle={'w','h','ax','ay'}}

	e.active = true
	e.texture = t.texture
	e.x = t.x
	e.y = t.y
	e.ax = t.ax or 0.5
	e.ay = t.ay or 0.5
	e.sx = t.sx or 1
	e.sy = t.sy or 1
	e.rotate = t.rotate or 0
	e.color = t.color or 0xffffffff
	return e
end


-- start
local background = create.sprite{ tex=gfx.texture('examples/assert/bg.jpg'), x=480, y=320 }
local helloworld = create.label{ text='Hello World', x=480, y=320, fontsize=48, color=0xff0000ff }

local bird_tex = gfx.texture('examples/assert/bird0_0.png')
local bird = create_sprite{ texture=bird_tex, x=480, y=420 }


local world = ecs.world()
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