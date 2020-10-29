local kite = require "kite"
local ui = require "kite.ui"
local gfx = require "graphics.core"
local thread = require "kite.thread"
local fontmgr = require "kite.manager.font"

local thread_receive = thread.start({}, "noblock")
local audio = thread.fork("examples/helloworld/thread/audio.lua", "audio")


fontmgr.load('generic', 'font/generic.fnt', 'font/generic_0.png')


local tree = ui.tree {
	type="empty", x=576, y=324, script="script.game",
	{name="bg", type="sprite", x=0, y=-30, width=1152, height=648+60, image="image/bg.jpg"},

	-- left cloud
	{type="sprite", x=-576+200/2, y=324-100/2, width=200, height=100, image="image/cloud_left.png"},
	{type="sprite", x=-576+100/2, y=324-42/2, width=100, height=42, image="image/clouds_left.png"},
	
	-- right cloud	
	{type="sprite", x=576-200/2, y=324-100/2, width=200, height=100, image="image/cloud_right.png"},
	{type="sprite", x=576-100/2, y=324-42/2, width=100, height=42, image="image/clouds_right.png"},

	{type="sprite", x=0, y=-200, width=1152, height=50, image="image/cloud_bottom.png"},
	{
		x = 0, y = 130, type = "empty",
		{name="circle1", type="sprite", x=0, y=0, width=700, height=700, image="image/button_bgs.png"},
		{name="circle2", type="sprite", x=0, y=0, width=700, height=700, image="image/button_bgss.png"},
		{name="circle3", type="sprite", x=0, y=0, width=112, height=112, image="image/button_bg.png"},
		{name="music", type="sprite", x=0, y=0, width=76, height=76, image="image/music.png"}
	},

	{name="button", type="label", x=0, y=-100, width=200, height=32, text="start game", font="generic", size=24, color=0x868686ff, script="script.button"},
	{name="textfield", type="textfield", x=0, y=-200, width=180, height=32, text="", font="generic", size=24, bg_image = "image/white.png", cursor_image="image/white.png"},
	-- bottom
	{type="sprite", x=0, y=-324+96/2, width=1920, height=96, image="image/footerBg.jpg"},
}



local game = {}


function game.update(dt)
	thread_receive()
	tree.dispatch("update", dt)
end

function game.draw()
	tree.draw()
end


function game.mouse(what, x, y, who)
	if who == "right" then
		return
	end
	tree.dispatch("mouse_"..what, x, y)
end

function game.keyboard(what, key)
	if what == "press" then
		tree.dispatch("keydown", key)
	else
		tree.dispatch("keyup", key)
	end
end

function game.textinput(char)
	tree.dispatch("textinput", char)
end

function game.scroll(ox, oy)
end

function game.pause()
end

function game.resume()
end

function game.exit()
	audio.send("exit")
end



kite.start(game)