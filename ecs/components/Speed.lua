return function (t)
	local speed = {
		type = 'speed',
		name = t.name,
		x = t.x or 0,
		y = t.y or 0
	}


	return speed
end