return function (entity, t)
	local meta = {
		x = t.x or 0,
		y = t.y or 0,
	}
 	
 	local speed = {'x', 'y'}

	return 'speed', setmetatable(speed, {__index = meta, __newindex = function (_, k, v)
		meta[k] = v
	end})
end