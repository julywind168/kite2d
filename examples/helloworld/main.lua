----------------------------------------------------------------------------------------
--
-- HelloWorld 就是为了演示 精灵 和 Label 的绘制
-- kite 参考了 ejoy2d, https://github.com/ejoy/ejoy2d
-- kite 还参考了 love2d 的api设计, https://love2d.org/ 
-- 
----------------------------------------------------------------------------------------


local kite = require 'kite'
local gfx = require "kite.graphics"


local game = {}

function game.update(dt)
	-- print('fps: ' .. math.floor(1/dt))
	-- print('cal: ' .. kite.drawcall())
end

function game.draw()
	gfx.draw('examples/asset/bg.jpg', 480, 320)	
	gfx.print('hello world 哈哈 O(∩_∩)O~', 48, 480, 320, 0xff0000ff)	
end

function game.mouse(what, x, y, who)
end

function game.keyboard(key, what)
	if key == 'escape' then
		kite.exit()
	end
end

function game.message(char)
end

function game.resume()
end

function game.pause()
end

function game.exit()
	print('see you next version, current is v'..kite.version())
end

kite.start(game)