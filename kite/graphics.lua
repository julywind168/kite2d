local core = require "graphics.core"
local font = require "kite.font"


local M = {}


function M.draw(tex, x, y, ax, ay, sx, sy, rotate, color, w, h)
	ax = ax or 0.5
	ay = ay or 0.5
	sx = sx or 1
	sy = sy or 1
	rotate = rotate or 0
	color = color or 0xffffffff
	core.draw(tex, x, y, ax, ay, sx, sy, rotate, color, w, h)
end


function M.print(text, size, x, y, ax, ay, rotate, color, fontname)
	local ft = font.create(fontname, size)
	local chars, length = ft.load(text)
	local height = size + 2
	core.print(chars, x, y, x - ax * length, y-(ay-0.24)*height, rotate, color)
end


return setmetatable(M, {__index = core})