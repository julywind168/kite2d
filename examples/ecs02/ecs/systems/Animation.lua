local gfx = require "kite.graphics"

local function Animation(world)

	local self = {name='animation'}

	local function get_flipbooks()
		return world.get_entities(function (e)
			return e.has['flipbook'] and e.active and not e.pause and not e.stop
		end)
	end

	function self.update(dt)
		local flipbooks = get_flipbooks()
		for _,e in ipairs(flipbooks) do
			e.timec = e.timec + dt
			local interval = 0.2/e.speed
			if e.timec >= interval then
				e.timec = e.timec - interval
				e.current = e.current + 1
				if e.current > #e.frames then
					e.current = 1
					if e.isloop == false then
						e.timec = 0
						e.stop = true
					end  
				end
			end
		end
	end

	return self
end

return function (...)
	return function (world, ...)
		return Animation(world, ...)
	end
end