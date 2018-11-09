local fantasy = require "fantasy"
local window = require "fantasy.window"
local system = require "fantasy.system"
local graphics = require "graphics.core"


local game = {}


local sp1, sp2, texture
local sprites = {}


function game.init()
	for i=1,2000 do
		sprites[i] = graphics.sprite(480, 320, 960, 640, 0xFF0000FF, 1, 1, 0)
	end
	texture = graphics.texture("examples/asset/bg.jpg");
end


function game.update(dt)
	print('fps:', 1//dt)
end


function game.draw()


	for _,sp in ipairs(sprites) do
		graphics.draw(sp, texture)	
	end
	
	-- graphics.draw(sp2, texture)
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


window('width', 960)
window('height', 640)
window('title', 'Fantasy 5000 draw')

fantasy.start(game)