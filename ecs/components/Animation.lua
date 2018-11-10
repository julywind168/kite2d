local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


return function (entity, t)
	local meta = {
		frames = assert(t.frames),
		isloop = assert(t.isloop),
		interval = assert(t.interval)
	}
 	
 	local animation = {'frames', 'isloop', 'interval'}
	
	local node = assert(entity.node, 'must need node component')
	local vao, vbo = graphics.sprite(
		node.x, node.y,
		node.scalex*node.width/window.width,
		node.scaley*node.height/window.height,
		node.rotate,
		texcoord and table.unpack(texcoord))


	entity('vao', vao)
	entity('vbo', vbo)
	entity('texture', t.frames[1])

	return 'animation', setmetatable(animation, {__index = meta, __newindex = function (_, k, v)
		meta[k] = v
	end})
end