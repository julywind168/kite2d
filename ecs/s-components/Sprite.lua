local ecs = require "ecs"
local graphics = require "ecs.graphics"
local util = require "ecs.util.sprite"


local function Sprite(e, t)
	local self = {
		active = (t.active ~= false) and true or false,
		camera = (t.camera ~= false) and true or false,
		color = t.color or 0xffffffff,

		texname = t.texname or 'resource/white.png',
		texcoord = t.texcoord or {0,1, 0,0, 1,0, 1,1},
		aabb = {{},{},{},{}}
	}

	local vao, vbo, texture
	local aabb

	function self.init()
		assert(e.components['transform'] and e.components['rectangle'])
		aabb = e.aabb
		util.e_calc_aabb(e)

		texture = graphics.texture(e.texname)
		vao, vbo = graphics.sprite(aabb[1].x, aabb[1].y, aabb[2].x, aabb[2].y, aabb[3].x, aabb[3].y, aabb[4].x, aabb[4].y,
			table.unpack(e.texcoord))

		-- hook
		local function update_aabb()
			util.e_calc_aabb(e)
			graphics.update_sprite_aabb(vbo, aabb[1].x, aabb[1].y, aabb[2].x, aabb[2].y, aabb[3].x,	aabb[3].y, aabb[4].x, aabb[4].y)
		end

		local after = getmetatable(e)

		for _,k in ipairs({'x', 'y', 'sx', 'sy', 'ax', 'ay', 'angle'}) do
			after.set[k] = update_aabb
		end

		function after.set.texname(name)
			texture = graphics.texture(name)
		end

		function after.set.texcoord(coord)
			graphics.update_sprite_aabb(vbo, table.unpack(coord))
		end
	end

	function self.draw()
		if e.active then
			graphics.set_sp_color(e.color)
			graphics.draw_sprite(vao, e.camera, texture)
		end
	end

	return self
end

return function (t)
	return function (e)
		return 'sprite', Sprite(e, t or {})
	end
end