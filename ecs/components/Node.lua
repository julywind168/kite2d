return function (entity, t)
	local node = {
		x = assert(t.x),
		y = assert(t.y),
		z = t.z or 0,
		width = t.width or 0,
		height = t.height or 0,
		scalex = t.scalex or 1,
		scaley = t.scaley or 1,
		rotate = t.rotate or 0,
		color = t.color or 0XFFFFFFFF,
	}

	return 'node', node
end