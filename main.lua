local fantasy = require "fantasy"
local window = require "fantasy.window"
local system = require "fantasy.system"

local game = {}


function game.init()
	window('title', 'My First Game')
	window('width', 960)
	window('height', 640)
end


function game.update(dt)
	print('update', dt)
end


function game.draw()
end


function game.mouse(what, x, y, who) -- 'PRESS'/'RELEASE/MOVE' 0, 0, 'LEFT'/'RIGHT'(on windows)
	if what == 'MOVE' then return end
	print('mouse:', what, x, y, who)
end


function game.keyboard(key, what)	-- 'a', 'PRESS'/'RELEASE'
	print('key', key, what)
end


function game.resume()
end

function game.pause()
end

function game.exit()
end


fantasy.start(game)