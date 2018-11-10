local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


return function (entity, comp)

	local node = assert(entity.node, 'must need node component')

	local vao, vbo = graphics.sprite(
		node.x, node.y,
		node.scalex*node.width/window.width,
		node.scaley*node.height/window.height,
		node.rotate,
		texcoord and table.unpack(texcoord))


	local sprite = {
		texture = graphics.texture(comp.texture),
		texcoord = comp.texcoord or {0,0, 0,1, 1,1, 1,0} ,
	}

	entity('vao', vao)
	entity('vbo', vbo)

	return 'sprite', sprite
end