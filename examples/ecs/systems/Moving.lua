local foreach = foreach

local function Move(world)

	local self = {}
	
	function self.update(dt)
		foreach(function (e)
			if not e.has['move'] then return end

			local distance = e.speed * dt
			e.x = e.x + distance * math.cos(e.direction * math.pi/180)
			e.y = e.y + distance * math.sin(e.direction * math.pi/180)

		end, world.scene)
	end

	return self
end


return function ()
	return function (world)
		return Move(world)
	end
end