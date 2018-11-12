return function (t)
	local ani = {
		type = 'animation',
		name = t.name,
		frames = assert(t.frames),
		interval = assert(t.interval),
		isloop = t.isloop or true,
		pause = t.pause or false,
		dt = 0,
		current = t.current or 1
	}

	for i,sp in ipairs(t.frames) do
		if i ~= ani.current then
			sp.active = false
		else
			sp.active = true
		end
	end

	return ani
end

