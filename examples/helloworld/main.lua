local kite = require 'kite'
local gfx = require "kite.graphics"



local bg = gfx.texture('examples/assert/bg.jpg')


local game = {}

function game.start()
end

function game.update(dt)
	-- print(1//dt)
end

function game.draw()
	gfx.draw(bg, 480, 320, 0.5, 0.5, 1, 1, 0, 0xffffffff)
	gfx.print('hello 哈哈旭旭宝宝123 | O(∩_∩)O', 24, 480, 640-2, 0.5, 1, 0, 0xff0000ff)	
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
	print('see you')
end

kite.start(game)