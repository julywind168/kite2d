local fant = require "fantasy"

return function (e, tick)
	local tick = tick or 1

	local self = {}

	local time = 0

	function self.update(dt)
		time = time + dt
		if time > tick then
			time = 0
			e.label.text = 'fps:' .. fant.fps
		end
	end


	return 'fps', self
end