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


return function (node, mt, proxy)
	node.color = node.color or 0xffffffff
	node.xalign = node.xalign or "center"
	node.yalign = node.yalign or "center"
	
	mt.world_width = node.width * mt.world_xscale
	mt.world_height = node.height * mt.world_yscale

	local label = gfx.label {
		x = mt.world_x,
		y = mt.world_y,
		angle = mt.world_angle,
		xscale = mt.world_xscale,
		yscale = mt.world_yscale,

		text = node.text,
		font = node.font,
		color = node.color,
		size = node.size,
		xalign = node.xalign,
		yalign = node.yalign
	}

	function mt.draw()
		label.draw()
	end

	function mt.update_transform()
		label.x = mt.world_x
		label.y = mt.world_y
		label.xscale = mt.world_xscale
		label.yscale = mt.world_yscale
		label.angle = mt.world_angle
		label.update_transform()
	end

	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if k == "color" then
			assert(type(v) == "number" and v >= 0)
			node.color = v
			label.set_color(v)
		elseif k == "text" then
			local text = v
			if limit and utf8.len(text) > limit then
				text = get_limit_text(text, limit)
			end
			node.text = text
			label.set_text(text)
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