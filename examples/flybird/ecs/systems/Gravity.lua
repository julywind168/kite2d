local physics_g = 200

local function Gravity(world)

	local self = {}

	local game = world.find_entity('game')
	local bird = world.find_entity('bird')
	local camera = world.find_entity('camera')
	local btn_play = world.find_entity('btn_play')
	local textfield = world.find_entity('textfield')

	function self.update(dt)
		if game.state ~= 'gameing' then return end
		if bird.y > game.land then
			local yspeed = math.sin(bird.direction * math.pi/180) * bird.speed
			yspeed = yspeed - physics_g * dt

			bird.speed = math.sqrt(game.bird_x_speed^2 + yspeed^2)
			bird.direction = math.asin(yspeed/bird.speed) * 180/math.pi
			bird.rotate = bird.direction
		else
			bird.speed = 0
			game.state = 'ready'
			btn_play.active = true
			textfield.active = true
			bird.x = 480
			bird.y = 420
			bird.rotate = 0
			camera.x = bird.x - 480
		end
	end

	return self
end


return function ()
	return function (world)
		return Gravity(world)
	end
end