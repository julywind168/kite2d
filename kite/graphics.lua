local core = require "graphics.core"
local font = require "kite.font"


local M = {}



local textures = {}

function M.texture(name)
	local tex = textures[name]
	if tex then
		return tex
	end

	local id, w, h = core.texture(name)
	textures[name] = { id = id, w = w, h = h }
	return textures[name]
end


function M.draw(texname, x, y, ax, ay, rotate, color, w, h, texcoord)
	local tex = M.texture(texname)
	ax = ax or 0.5
	ay = ay or 0.5
	rotate = rotate or 0
	color = color or 0xffffffff
	w = w or tex.w
	h = h or tex.h
	texcoord = texcoord or {0,1, 0,0, 1,0, 1,1}
	core.draw(tex.id, x, y, ax, ay, rotate, color, w, h, table.unpack(texcoord))
end


function M.print(text, size, x, y, color, ax, ay, rotate, fontname, only_width)
	ax = ax or 0.5
	ay = ay or 0.5
	rotate = rotate or 0

	local ft = font.create(fontname, size)
	local chars, width = ft.load(text)

	if only_width then return width end

	core.print(chars, x, y, x - ax * width, y-(ay-0.2)*size, rotate, color)
end


return setmetatable(M, {__index = core})