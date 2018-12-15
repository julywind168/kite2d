local physics_g = 180

local function Gravity(world)

	local self = {}

	local game = world.find_entity('game')
	local bird = world.find_entity('bird')

	function self.update(dt)
		if bird.y > game.land then
			local yspeed = math.sin(bird.direction * math.pi/180) * bird.speed
			yspeed = yspeed - physics_g * dt

			bird.speed = math.sqrt(game.bird_x_speed^2 + yspeed^2)
			bird.direction = math.asin(yspeed/bird.speed) * 180/math.pi
			bird.rotate = bird.direction
		end
	end

	return self
end


return function ()
	return function (world)
		return Gravity(world)
	end
end