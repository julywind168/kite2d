local function Rectangle(e, t)

	local self = {
		w = t.w or 0,
		h = t.h or 0,
		ax = t.ax or 0.5,	-- anchor X
		ay = t.ay or 0.5,	-- anchor Y
	}
	return self
end


return function (t)
	return function (e)
		return 'rectangle', Rectangle(e, t or {})
	end
end