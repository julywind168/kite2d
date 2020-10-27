local kite = require "kite"
local ui = require "kite.ui"
local gfx = require "graphics.core"
local fontmgr = require "kite.manager.font"


fontmgr.load('generic', 'font/generic.fnt', 'font/generic_0.png')


local tree = ui.tree {type="empty", x=application.design_width/2, y=application.design_height/2, script="script.editor"}



local game = {}


function game.update(dt)
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
end



kite.start(game)