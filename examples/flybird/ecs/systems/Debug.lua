local gfx = require 'kite.graphics'

local function Debug(world)

	local self = {}
	

	local fps = 60

	local count = 0
	function self.update(dt)
		count = count + dt
		if count > 0.5 then
			count = 0
			fps = math.floor(1//dt)
		end
	end

	function self.draw()
		gfx.print('FPS:'..fps, 20, 960-75, 640-10, 0x554411ff, 0, 1, 0)
	end

	return self
end


return function ()
	return function (world)
		return Debug(world)
	end
end