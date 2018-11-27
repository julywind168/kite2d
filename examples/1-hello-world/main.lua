local ft = require "fantasy"

local bg, fps, helloworld1, helloworld2


local font = {
	arial = "examples/asset/font/arial.ttf",
	msyh = "C:/Windows/Fonts/msyh.ttc"		-- win10 is ok
}


local game = {init = function()
	bg = ft.sprite {texname="examples/asset/bg.jpg", x=480, y=320, w=960, h=640}
	fps = ft.label {fontname=font.arial, text='fps:60', x=20, y=620, anchorx=0, anchory=1, color=0x554411ff}
	helloworld1 = ft.label {fontname=font.arial, text='hello world', x=480, y=320, color=0xff0000ff, size=48}
	helloworld2 = ft.label {fontname=font.msyh, text='求捐赠^.^', x=960, y=0, anchorx=1, anchory=0, color=0x778866ee, size=36}
end}



function game.update(dt)
	fps.text = 'fps:'..ft.fps
end


function game.draw()
	ft.clear(0x777777ff)
	bg.draw()
	fps.draw()
	helloworld1.draw()
	helloworld2.draw()
end


function game.mouse(what, x, y, who)
end

function game.keyboard(key, what)
	print("keyboard", key, what)
end

function game.message(char)
	print("message", char)
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