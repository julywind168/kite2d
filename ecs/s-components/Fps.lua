local function Fps(e, t)

	local self = {}

	local tick = tick or 0.5
	local time = 0

	function self.init()
		assert(e.components['label'], 'no label component')
	end

	function self.update(dt)
		time = time + dt
		if time >= tick then
			time = 0
			e.text = 'fps:'..math.floor(1//dt)
		end
	end

	return self
end

return function (t)
	return function (e)
		return 'fps', Fps(e, t)
	end
end