local fantasy = require "fantasy"
local graphics = require "fantasy.graphics"

local function new_sprite(texname, ...)
	local texture = graphics.texture(texname)

	local vao, vbo = graphics.sprite(...)

	return function ()
		graphics.draw_sprite(vao, texture)
	end
end


local bg, smile


local game = {init = function()
	bg = new_sprite("examples/asset/bg.jpg", 0, 640, 0, 0, 960, 0, 960, 640)
	smile = new_sprite("examples/asset/smile.jpg", 300, 540, 300, 100, 860, 100, 860, 540)
end}


function game.update(dt)
end


function game.draw()
	bg()
	-- smile()
	graphics.draw_text("examples/asset/font/arial.ttf", "Hello World! 123456789...",50, 550, 36, 0Xaa7733ff)
	graphics.draw_text("examples/asset/font/msyh.ttc", "大家好 O(∩_∩)O",50, 550-100, 36, 0Xff2222ff)
end


function game.mouse(what, x, y, who)
end

function game.keyboard(key, what)
end

function game.resume()
end

function game.pause()
end

function game.exit()
end


local config = {
	window = {
		x = 1920/2,
		y = 1080/2,
		width = 960,
		height = 640,
		title = 'Hello World',
		fullscreen = false
	}
}


fantasy.start(config, game)