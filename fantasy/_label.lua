local graphics = require "graphics.core"
local font_core = require "font.core"

local TX_CUR_COLOR = 0xffffffff
local fonts = {}


local function set_tx_color(c)
	if c ~= TX_CUR_COLOR then
		TX_CUR_COLOR = c
		graphics.set_tx_color(c)
	end
end

local function get_font(filename, size)
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


local function label(t)
	local self = {
		x = t.x or 0,
		y = t.y or 0,
		w = nil,
		h = t.size or 36,
		angle = t.angle or 0,
		anchorx = t.anchorx or 0.5,
		anchory = t.anchory or 0.5,
		color = t.color or 0xffffffff,
		text = assert(t.text),
		fontname = assert(t.fontname),
		size = t.size or 24,
		camera = t.camera and true or false
	}

	local font = get_font(self.fontname)
	local scale = self.size/font.size
	local chars = font.chars(self.text)

	self.w = font_core.chars_length(chars, scale)

	function self.draw()
		set_tx_color(self.color)
		graphics.draw_text(self.x - self.anchorx * self.w, self.y - (self.anchory - 0.5)*self.h, scale, chars, self.angle)
	end


	local function set(_, k, v)
		assert(self[k], "label don't has this property")
		if k == 'text' then
			self.text = v
			chars = font.chars(self.text)
			self.w = font_core.chars_length(chars, scale)
		else
			self[k] = v
		end
	end

	return setmetatable(self, {__call = set})
end


return label