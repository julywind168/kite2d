---------------------------------------------------------------
--
-- texture manager
--
---------------------------------------------------------------
local kite = require "kite.core"
local gfx = require "graphics.core"


local M = {}
local loaded = {}


local function load_texture(filename, basedir)
	basedir = basedir or kite.gamedir
	local id, w, h = gfx.texture(basedir.."/"..filename)
	local tex = { id = id, name = filename,  width = w, height = h }
	loaded[filename] = tex
	return tex
end


function M.query(filename)
	return loaded[filename] or load_texture(filename)
end


function M.preload(filename, basedir)
	if type(filename) == "table" then
		for _,fn in ipairs(filename) do
			load_texture(fn, basedir)
		end
	else
		load_texture(filename, basedir)
	end
end



return M