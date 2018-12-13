local kite = require 'kite'
local gfx = require "kite.graphics"



local bg = gfx.texture('examples/assert/bg.jpg')


local game = {}

function game.update(dt)
end

function game.draw()
	gfx.draw(bg, 480, 320, 0.5, 0.5, 1, 1, 0, 0xffffffff)
	gfx.print('hello world 哈哈 O(∩_∩)O~', 48, 480, 320, 0.5, 0.5, 0, 0xff0000ff)	
end

function game.mouse(what, x, y, who)
end

function game.keyboard(key, what)
	if key == 'escape' then
		kite.exit()
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