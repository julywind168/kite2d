local foreach = foreach

local function Animation(world)

	local self = {name='animation'}


	function self.update(dt)

		foreach(function (e)
			if e.type ~= 'flipbook' then return end
			
			e.timec = e.timec + dt
			local interval = 0.167/e.playspeed -- play speed max is 10
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
		end, world.entities)
	end

	return self
end

return function (...)
	return function (world, ...)
		return Animation(world, ...)
	end
end