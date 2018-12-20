local foreach = foreach
local physics_g = 200

local function Gravity(world)

	local self = {}

	function self.update(dt)

		foreach(function (e)
			if not e.has['position'] or not e.has['move'] or not e.has['mass'] or e.mass == 0 then return end

				local xspeed = math.cos(e.direction * math.pi/180) * e.speed
				local yspeed = math.sin(e.direction * math.pi/180) * e.speed
				yspeed = yspeed - physics_g * dt

				e.speed = math.sqrt(xspeed^2 + yspeed^2)
				e.direction = math.asin(yspeed/e.speed) * 180/math.pi
				e.rotate = e.direction
		end, world.entities)
	end

	return self
end


return function ()
	return function (world)
		return Gravity(world)
	end
end