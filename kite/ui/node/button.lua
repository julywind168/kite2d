local gfx = require "kite.graphics"


local transform_attr = {x=true, y=true, width=true, height=true, xscale=true, yscale=true, angle=true}


return function (node, proxy)
	node.color = node.color or 0xffffffff
	node.hflip = node.hflip and true or false
	node.vflip = node.vflip and true or false

	proxy.world_width = node.width * proxy.world_xscale
	proxy.world_height = node.height * proxy.world_yscale

	local sprite = gfx.sprite {
		x = proxy.world_x,
		y = proxy.world_y,
		width = proxy.world_width,
		height = proxy.world_height,
		angle = proxy.world_angle,

		image = node.image,
		color = node.color,
		hflip = node.hflip,
		vflip = node.vflip
	}

	-- mt func (use by framwork)
	function proxy.draw()
		sprite.draw()
	end

	function proxy.update_transform()
		proxy.world_width = node.width * proxy.world_xscale
		proxy.world_height = node.height * proxy.world_yscale

		sprite.x = proxy.world_x
		sprite.y = proxy.world_y
		sprite.width = proxy.world_width
		sprite.height = proxy.world_height
		sprite.angle = proxy.world_angle
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

	-- button attr
	proxy.touchable = true

	local normal_xscale
	local normal_yscale

	function proxy.touch_began()
		normal_xscale = node.xscale
		normal_yscale = node.yscale

		proxy.xscale = node.press_scale * normal_xscale
		proxy.yscale = node.press_scale * normal_yscale
	end

	function proxy.touch_ended()
		proxy.xscale = normal_xscale
		proxy.yscale = normal_yscale
	end

	
	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if k == "color" then
			assert(type(v) == "number" and v >= 0)
			node.color = v
			sprite.set_color(v)
		elseif node[k] then
			if transform_attr[k] then
				node[k] = v
				proxy.modified = true
			else
				error(k.." is read-only")
			end
		else
			rawset(proxy, k, v)
		end
	end})
end