local graphics = require "graphics.core"
local font_core = require "font.core"

-- TEXTURE

local textures = {}
local SP_CUR_COLOR = 0xffffffff

local function get_texture(texname)
	local tex = textures[texname]
	if tex then return tex end

	tex = graphics.texture(texname)

	textures[texname] = tex
	return tex
end


-- FONT

local fonts = {}
local TX_CUR_COLOR = 0xffffffff

local function get_font(name, size)
	local size = size or 48
	local font = fonts[name]
	if font then return font end

	font = { face = font_core.face(name, size), size = size, loaded = {} }

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

	fonts[name] = font
	return font
end





local M = {}


function M.texture(name)
	return get_texture(name)
end

function M.font(name)
	return get_font(name)
end

function M.set_tx_color(c)
	if c ~= TX_CUR_COLOR then
		TX_CUR_COLOR = c
		graphics.set_tx_color(c)
	end
end

function M.set_sp_color(c)
	if c ~= SP_CUR_COLOR then
		SP_CUR_COLOR = c
		graphics.set_sp_color(c)
	end
end

M.chars_length = font_core.chars_length


return setmetatable(M, {__index=graphics})