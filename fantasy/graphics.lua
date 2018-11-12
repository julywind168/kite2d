local core = require "graphics.core"


local M = {}


local textures = {}

function M.texture(filename)
	local tex = textures[filename]
	if tex then
		return tex
	else
		tex = core.texture(filename)
		textures[filename] = tex
		return tex
	end
end


return setmetatable(M, {__index = core})
