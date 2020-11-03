local gfx = require "kite.graphics"
local transform_attr = {x=true, y=true, width=true, height=true, xscale=true, yscale=true, angle=true}


return function (node, proxy)
	node.color = node.color or 0xffffffff
	node.hflip = node.hflip and true or false
	node.vflip = node.vflip and true or false
	node.anchor = node.anchor or {x = 0.5, y = 0.5}

	proxy.world_width = node.width * proxy.world_xscale
	proxy.world_height = node.height * proxy.world_yscale

	local sprite = gfx.sprite {
		x = proxy.world_x,
		y = proxy.world_y,
		width = proxy.world_width,
		height = proxy.world_height,
		angle = proxy.world_angle,
		anchor = node.anchor,

		image = node.image,
		texcoord = node.texcoord,
		color = node.color,
		hflip = node.hflip,
		vflip = node.vflip
	}

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

	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if k == "color" then
			assert(type(v) == "number" and v >= 0)
			node.color = v
			sprite.set_color(v)
		elseif k == "image" then
			node.image = v
			sprite.set_image(v)
		elseif k == "texcoord" then
			node.texcoord = v
			sprite.set_texcoord(v)
		elseif k == "anchor" then
			node.anchor = v
			sprite.set_anchor(v)
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