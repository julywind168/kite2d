local fantasy = require "fantasy"
local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


local function create_sprite(x, y, width, height, scalex, scaley, rotate, image)
	local vao, vbo = graphics.sprite(
		x, y,
		scalex*width/window.width,
		scaley*height/window.height,
		rotate)

	local texture = graphics.texture(image)

	local self = {}
	function self.draw()
		graphics.draw(vao, texture)
	end
	return self
end



local game = {}

local bg, bird

function game.init()
	bg = create_sprite(480, 320, 960, 640, 1, 1, 0, "examples/asset/bg.jpg")
	bird = create_sprite(480, 320, 48, 48, 1, 1, 0, "examples/asset/bird0_0.png")
end


function game.update(dt)
	-- print('fps:', 1//dt)
end


function game.draw()
	bg.draw()
	bird.draw()
end


function game.mouse(what, x, y, who) -- 'PRESS'/'RELEASE/MOVE' 0, 0, 'LEFT'/'RIGHT'(on windows)
end


function game.keyboard(key, what)	-- 'a', 'PRESS'/'RELEASE'
	if what == 'RELEASE' then
		if key == 'f' then
			window.fullscreen = true
		elseif key == 'w' then
			window.fullscreen = false
		end
	end
end


function game.resume()
end

function game.pause()
end

function game.exit()
end


local config = {
	window = {
		width = 960,
		height = 640,
		title = 'Hello World',
		fullscreen = false
	},
	camera = {
		x = 480,
		y = 320
	}
}

fantasy.start(config, game)