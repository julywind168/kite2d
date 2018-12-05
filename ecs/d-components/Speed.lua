local function Speed(e, t)

	local self = {
		direction = t.direction or 0, -- 逆时针角度
		speed = t.speed or 0
	}
	return self
end


return function (t)
	return function (e)
		return 'speed', Speed(e, t or {})
	end
end