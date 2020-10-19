local gfx = require "kite.graphics"
local transform_attr = {x=true, y=true, width=true, height=true, xscale=true, yscale=true, angle=true}


return function (node, mt, proxy)
	node.color = node.color or 0xffffffff
	node.hflip = node.hflip and true or false
	node.vflip = node.vflip and true or false

	mt.world_width = node.width * mt.world_xscale
	mt.world_height = node.height * mt.world_yscale

	local sprite = gfx.sprite {
		x = mt.world_x,
		y = mt.world_y,
		width = mt.world_width,
		height = mt.world_height,
		angle = mt.world_angle,

		image = node.image,
		color = node.color,
		hflip = node.hflip,
		vflip = node.vflip
	}

	-- mt func (use by framwork)
	function mt.draw()
		sprite.draw()
	end

	function mt.update_transform()
		mt.world_width = node.width * mt.world_xscale
		mt.world_height = node.height * mt.world_yscale

		sprite.x = mt.world_x
		sprite.y = mt.world_y
		sprite.width = mt.world_width
		sprite.height = mt.world_height
		sprite.angle = mt.world_angle
		sprite.update_transform()
	end

	-- proxy func (use by user)
	function proxy.flip_h()
		sprite.flip_h()
		node.hflip = not node.hflip
	end

	function proxy.flip_v()
		sprite.flip_v()
		node.vflip = not node.vflip
	end

	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if k == "color" then
			assert(type(v) == "number" and v >= 0)
			node.color = v
			sprite.set_color(v)
		elseif node[k] then
			if transform_attr[k] then
				mt.modify[k] = v
			else
				error(k.." is read-only")
			end
		else
			rawset(proxy, k, v)
		end
	end})
end