local kite = require 'kite'
local gfx = require 'kite.graphics'
local ecs = require 'kite.ecs'

local RenderSystem = require 'kite.ecs.systems.Render'


local bg = gfx.texture('examples/assert/bg.jpg')


local function create_sprite(texture, t)
	local e = {}
	e.has = {position=true, sprite=true}
	e.active = true
	e.texture = texture
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





local world = ecs.world()
	.add_system(RenderSystem)
	.add_entity(create_sprite(bg, {x = 480, y = 320}))


local game = {}

function game.update(dt)
	world('update', dt)
end

function game.draw()
	world('draw')
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