local util = require "ecs.util.node"

return function (e, t)
	local self = {
		active = (t.active ~= false) and true or false,
		camera = (t.camera ~= false) and true or false,
		x = assert(t.x),
		y = assert(t.y),
		z = t.z or 0,
		width = t.width or 0,
		height = t.height or 0,
		angle = t.angle or 0,
		anchor = t.anchor or {x=0.5, y=0.5},
		scale = t.scale or {x=1, y=1},
		aabb = {{}, {}, {}, {}}
	}


	util.node_calc_aabb(self)

	return 'node', self
end