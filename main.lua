local fantasy = require "fantasy"
local window = require "fantasy.window"
local system = require "fantasy.system"
local graphics = require "graphics.core"


local game = {}


local sp, texture


function game.init()
	sp = graphics.sprite()
	texture = graphics.texture("examples/asset/bg.jpg");
end


function game.update(dt)
	-- print('update', dt)
end


function game.draw()
	graphics.draw(sp, texture)
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


window('width', 800)
window('height', 600)
window('title', 'Hello Sprite')

fantasy.start(game)