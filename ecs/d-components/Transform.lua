local function Transform(e, t)

	local self = {
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,		-- scale X
		sy = t.sy or 1,		-- scale Y
		angle = t.angle or 0,
	}
	return self
end


return function (t)
	return function (e)
		return 'transform', Transform(e, t or {})
	end
end