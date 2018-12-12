local core = require "font.core"


local function is_exist(filename)
	local f = io.open(filename)
	if f then
		f:close()
		return filename
	end
end


local default = is_exist('C:/Windows/Fonts/msyh.ttc') or
				is_exist('C:/Windows/Fonts/msyh.ttf') or
				error('can\'t find font, please run kite in win10/win7')



local M = {}


local fonts = {}

function M.create(name)

	name = name or default
	if fonts[name] then return fonts[name] end

	local self = {}
	local face = core.face(name)

	-- cache start
	local loaded = {}
	local texts = {}
	-- cache end

	function self.load(text, size)

		local cache = texts[text]
		if cache then
			return cache[1], cache[2]
		end

		local chars = {}
		for _,id in utf8.codes(text) do
			local char = loaded[id]
			if not char then
				char = core.char(face, id)
				loaded[id] = char
			end
			table.insert(chars, char)
		end

		local length = core.chars_length(chars, size)
		texts[text] = {chars, length}
		return chars, length
	end

	fonts[name] = self

	return self
end


return setmetatable(M, {__index = core})