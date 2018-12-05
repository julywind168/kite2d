local ecs = require "ecs"
local graphics = require "ecs.graphics"
local util = require "ecs.util.sprite"


local function Sprite(e, t)

	local self = {
		color = t.color or 0xffffffff,
		texname = t.texname or 'resource/white.png',
		texcoord = t.texcoord or {0,1, 0,0, 1,0, 1,1},
		w = t.w or 0,
		h = t.h or 0,
		ax = t.ax or 0.5,
		ay = t.ay or 0.5,
		aabb = {{},{},{},{}}
	}

	local vao, vbo
	local aabb, texture

	function self.init()
		assert(e.components['node'] and e.components['transform'])
		
		texture = assert(graphics.texture(e.texname), e.texname)

		e.w = e.w ~= 0 and e.w or texture.w * (e.texcoord[7] - e.texcoord[1])
		e.h = e.h ~= 0 and e.h or texture.h * (e.texcoord[2] - e.texcoord[4])
		
		aabb = e.aabb
		util.e_calc_aabb(e)
		vao, vbo = graphics.sprite(aabb[1].x, aabb[1].y, aabb[2].x, aabb[2].y, aabb[3].x, aabb[3].y, aabb[4].x, aabb[4].y,
			table.unpack(e.texcoord))

		-- hook
		local function update_aabb()
			util.e_calc_aabb(e)
			graphics.update_sprite_aabb(vbo, aabb[1].x, aabb[1].y, aabb[2].x, aabb[2].y, aabb[3].x,	aabb[3].y, aabb[4].x, aabb[4].y)
		end

		for _,k in ipairs({'x', 'y', 'sx', 'sy', 'ax', 'ay', 'angle'}) do
			e.on('set_'..k, update_aabb)
		end

		e.on('set_texname', function (texname)
			texture = graphics.texture(texname)
		end)

		e.on('set_texcoord', function (texcoord)
			graphics.update_sprite_texcoord(vbo, table.unpack(texcoord))
		end)
	end

	function self.draw()
		if e.active then
			graphics.set_sp_color(e.color)
			graphics.draw_sprite(vao, e.camera, texture.data)
		end
	end

	return self
end

return function (t)
	return function (e)
		return 'sprite', Sprite(e, t or {})
	end
end