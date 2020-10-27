local gfx = require "kite.graphics"

local transform_attr = {x=true, y=true, xscale=true, yscale=true, angle=true}


local function get_limit_text(text, n)
	local t = {}
	local c = 0
	for _, code in utf8.codes(text) do
		table.insert(t, utf8.char(code))
		c = c + 1
		if c == n then
			break
		end
	end
	return table.concat(t, "")
end


return function (node, proxy)
	node.color = node.color or 0xffffffff
	node.xalign = node.xalign or "center"
	node.yalign = node.yalign or "center"
	
	proxy.world_width = node.width * proxy.world_xscale
	proxy.world_height = node.height * proxy.world_yscale

	local label = gfx.label {
		x = proxy.world_x,
		y = proxy.world_y,
		angle = proxy.world_angle,
		xscale = proxy.world_xscale,
		yscale = proxy.world_yscale,

		text = node.text,
		font = node.font,
		color = node.color,
		size = node.size,
		xalign = node.xalign,
		yalign = node.yalign
	}

	function proxy.draw()
		label.draw()
	end

	function proxy.update_transform()
		label.x = proxy.world_x
		label.y = proxy.world_y
		label.xscale = proxy.world_xscale
		label.yscale = proxy.world_yscale
		label.angle = proxy.world_angle
		label.update_transform()
	end

	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if k == "color" then
			assert(type(v) == "number" and v >= 0)
			node.color = v
			label.set_color(v)
		elseif k == "width" then
			node.width = v
			proxy.world_width = node.width * proxy.world_xscale
		elseif k == "height" then
			node.height = v
			proxy.world_height = node.height * proxy.world_yscale
		elseif k == "text" then
			local text = v
			if limit and utf8.len(text) > limit then
				text = get_limit_text(text, limit)
			end
			node.text = text
			label.set_text(text)
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