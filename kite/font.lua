local core = require "font.core"
local floor = math.floor


local function is_exist(filename)
	local f = io.open(filename)
	if f then
		f:close()
		return filename
	end
end


local default = is_exist('C:/Windows/Fonts/msyh.ttc') or
				is_exist('C:/Windows/Fonts/msyh.ttf') or
				error('can\'t find font, please run kite on win10/win7')



local M = {}


local fonts = {}

function M.create(name, sz)

	sz = floor(sz)
	name = name or default

	local cache = fonts[name] and fonts[name][sz]
	if cache then return cache end

	local self = {}
	local face = core.face(name, sz)

	-- cache start
	local loaded = {}
	local texts = {}
	-- cache end

	function self.load(text)

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

		local length = 0
		if #chars > 0 then
			length = core.chars_length(chars)
		end

		texts[text] = {chars, length}
		return chars, length
	end

	fonts[name] = fonts[name] or {}
	fonts[name][sz] = self

	return self
end


return setmetatable(M, {__index = core})