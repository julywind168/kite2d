local fantasy = require "fantasy"
local graphics = require "fantasy.graphics"



local bg, smile1, smile2
local font = {arial = "examples/asset/font/arial.ttf",
			  msyh = "examples/asset/font/msyh.ttc"}

local game = {init = function()
	bg = graphics.sprite {texname="examples/asset/bg.jpg", x=480, y=320, w=960, h=640}
	smile1 = graphics.sprite {texname="examples/asset/smile.jpg", x=0, y=320, w=260, h=260, anchory=0}
	smile2 = graphics.sprite {texname="examples/asset/smile.jpg", x=0, y=320, w=260, h=260, anchory=1, angle=45} 
end}



function game.update(dt)
	-- when call a component mean to set
	smile1('x', smile1.x + 1)
	smile2('x', smile2.x + 1)
end


function game.draw()
	bg.draw()
	smile1.draw()
	smile2.draw()
	graphics.draw_text(font.arial, "fps:"..fantasy.fps, 20, 600, 24, 0Xaa7733ff)
	graphics.draw_text(font.msyh, "大家好 O(∩_∩)O", 20, 500, 24, 0Xff2222ff)
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