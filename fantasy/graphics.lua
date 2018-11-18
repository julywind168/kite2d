local core = require "graphics.core"
local font_core = require "font.core"

local textures = {}
local fonts = {}

function get_font(filename, size)
	local size = size or 48
	local font = fonts[filename]
	if font then return font end

	font = { face = font_core.face(filename, size), size = size, loaded = {} }

	function font.chars(string)
		local r = {}
		for _,id in utf8.codes(string) do
			local char = font.loaded[id]
			if not char then
				char = font_core.char(font.face, id)
				font.loaded[id] = char
			end
			table.insert(r, char)
		end
		return r
	end

	fonts[filename] = font
	return font
end


local M = {}


function M.draw_text(fontname, string, x, y, size, color)
	local font = get_font(fontname)
	local chars = font.chars(string)
	local scale = size/font.size
	core.draw_text(x, y, scale, chars, color)
end


function M.new_texture(texname)
	local tex = textures[texname]
	if tex then return tex end

	tex = core.new_texture(texname)
	textures[texname] = tex
	return tex
end


return setmetatable(M, {__index = core})