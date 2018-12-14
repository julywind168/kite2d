----------------------------------------------------------------------------------------
--
-- Ecs01 主要是让大家适应一下 kite-ECS
-- 接下来, 我们将以 ECS 为基础构建一套简单的 UI 系统
-- kite-ECS 参考了: https://github.com/ephja/love-ecs
-- 在 Ecs02 中 我们将对ECS进行修改 以符合RPG游戏的需要  
--
-- kite-ECS: 设计规范
-- entity: 必须是可以序列化的纯数据(function, userdata 不允许出现, 为此我修改了graphics的绘制接口...)
-- system: 是一系列 handle(function) 的集合, system 内不允许有任何状态, 包括对 entity 的引用
--
-- 好处1: 方便的快照, 我们可以将 entity list 序列化后保持到文件，当重新加载运行时,便能复现场景
-- 好处2: 回放, 我们保存 entity list 后, 再保存 发送给world的事件, 便可回放(游戏内不要有真随机的逻辑即可)
-- 好处3: 由于entity是完全可序列化的, 所以我们能把 回放(entity list && events) 发送给服务器 （这感觉有点像上传视频!!!）
-- 
-- 再次提醒 例子中的 ecs实现(ecs/init.lua) 会 在后面的例子中根据 rpg 游戏的需要 不停更新, 但会遵循上面的规范
-- 
----------------------------------------------------------------------------------------
package.path = 'examples/ecs01/?.lua;examples/ecs01/?/init.lua;' .. package.path

local kite = require 'kite'
local gfx = require 'kite.graphics'
local ecs = require 'ecs'
local create = require 'ecs.functions'

local Render = require 'ecs.systems.Render'

--
-- 让我们手动构造一种 entity (纯数据的集合), 仅用于理解 与 create.sprite 效果一样
--
local function create_sprite(t, name)
	local e = {}
	e.name = name or 'unknown'
	e.has = {node={'active'},position={'x','y'},transform={'sx','sy','rotate'},sprite={'texname','texcoord','color'},rectangle={'w','h','ax','ay'}}

	e.active = true
	e.texname = t.texname
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
local background = create.sprite{ texname='examples/assert/bg.jpg', x=480, y=320 }
local helloworld = create.label{ text='Hello World', x=480, y=320, fontsize=48, color=0xff0000ff }

local bird = create_sprite{ texname='examples/assert/bird0_0.png', x=480, y=420 }


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