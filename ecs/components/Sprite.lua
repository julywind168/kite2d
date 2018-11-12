local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


return function (t)
	local sprite = {
		type = 'sprite',
		name = t.name,
		camera = (t.camera ~= false) and true or false,
		active = (t.active ~= false) and true or false,
		x = assert(t.x),
		y = assert(t.y),
		z = t.z or 1,
		width = assert(t.width),
		height = assert(t.height),
		scalex = t.scalex or 1,
		scaley = t.scaley or 1,
		rotate = t.rotate or 0,
		texname = t.texname,
		texcoord = t.texcoord or {0,0, 0,1, 1,1, 1,0}
		-- color = t.color or 0XFFFFFFFF,
	}

	return sprite
end