local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


return function (entity, t)
	local meta = {
		x = assert(t.x),
		y = assert(t.y),
		z = t.z or 1,
		width = t.width or 0,
		height = t.height or 0,
		scalex = t.scalex or 1,
		scaley = t.scaley or 1,
		rotate = t.rotate or 0,
		color = t.color or 0XFFFFFFFF,
	}

	local set = {}

	function set.x(x)
		meta.x = x
		
		local vbo = entity('vbo')
		if vbo then
			graphics.sprite_x(vbo, x)
		end
	end

	function set.y(y)
		meta.y = y
		
		local vbo = entity('vbo')
		if vbo then
			graphics.sprite_y(vbo, y)
		end
	end

 	
 	local node = {'x','y','z','width','height','scalex','scaley','rotate','color'}

	return 'node', setmetatable(node, {__index = meta, __newindex = function (_, k, v)
		local f = assert(set[k], 'unable to change this property: '..tostring(k))
		f(v)
	end})
end