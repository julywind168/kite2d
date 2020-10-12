---------------------------------------------------------------
--
-- bmpfont manager
--
---------------------------------------------------------------
local kite = require "kite.core"
local texmgr = require "kite.manager.texture"


local M = {}

local fonts = {}

local function load_bmpfont(name, fnt_path, bitmap_path)
	local f = assert(io.open(kite.gamedir.."/"..fnt_path, 'r'), fnt_path)
	local i = 0
	local tex = texmgr.query(bitmap_path)
	local font = { char = {}, kerning = {}, texture = tex }
	
	local char = font.char
	local kerning = font.kerning

	while true do
		i = i + 1
		local text = f:read('l')
		if text then

			local prop = string.match(text, "(%w+)")

			local t = {}
			for k, v in string.gmatch(text, "(%w+)=(-?%d+)") do
				t[k] = tonumber(v)
			end
			for k, v in string.gmatch(text, '(%w+)="([^"]*)') do
				t[k] = v
			end

			if prop == 'char' then
				t.id = tonumber(t.id)
				t.texcoord = {
					t.x/tex.width, (tex.height-t.y)/tex.height,
					t.x/tex.width, (tex.height-t.y-t.height)/tex.height,
					(t.x+t.width)/tex.width, (tex.height-t.y-t.height)/tex.height,
					(t.x+t.width)/tex.width, (tex.height-t.y)/tex.height 	
				}
				char[t.id] = t
			elseif prop == 'kerning' then 
				kerning[t.first] = kerning[t.first] or {}
				kerning[t.first][t.second] = t.amount 
			else
				font[prop] = t
			end
		else
			f:close()
			break
		end
	end

	font.info.size = math.abs(font.info.size)

	fonts[name] = font
	return font
end


function M.load(name, fnt_path, bmp_path)
	load_bmpfont(name, fnt_path, bmp_path)
end


function M.query(name, ...)
	return fonts[name] or load_bmpfont(name, ...)
end


return M