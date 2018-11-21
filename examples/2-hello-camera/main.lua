local ft = require "fantasy"


local camera
local fps, bg1, bg2

local font = {
	arial = "examples/asset/font/arial.ttf",
	msyh = "C:/Windows/Fonts/msyh.ttc"		-- win10 is ok
}

local game = {init = function()
	camera = ft.camera()
	bg1 = ft.sprite {texname="examples/asset/bg.jpg", x=480, y=320, w=960, h=640}
	bg2 = ft.sprite {texname="examples/asset/bg.jpg", x=480+960, y=320, w=960, h=640}
	fps = ft.label {fontname=font.arial, text='fps:60', x=20, y=620, anchorx=0, anchory=1, color=0x554411ff}
end}



function game.update(dt)
	fps('text', 'fps:'..ft.fps)

	-- move camera to right
	camera('x', camera.x + 2)
end


function game.draw()
	bg1.draw()
	bg2.draw()
	fps.draw()
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
		x = 1920/2,		-- screen pos
		y = 1080/2,		-- screen pos
		width = 960,
		height = 640,
		title = 'Hello World',
		fullscreen = false
	},
	camera = {
		x = 480,
		y = 320,
		scale = 1,
	}
}


ft.start(config, game)