local kite = require 'kite'
local gfx = require 'kite.graphics'

local function Debug(world)

	local self = {}
	

	local fps = 60
	local drawcall = 0

	local count = 0
	function self.update(dt)
		count = count + dt
		if count > 0.5 then
			count = 0
			fps = math.floor(1//dt)
			drawcall = kite.drawcall()
		end
	end

	function self.draw()
		gfx.print('Draw call', 20, 960-180, 630, 0x554411ff, 0, 1, 0)
		gfx.print(drawcall, 20, 960-10, 630, 0x554411ff, 1, 1, 0)

		gfx.print('FPS', 20, 960-180, 600, 0x554411ff, 0, 1, 0)
		gfx.print(fps, 20, 960-10, 600, 0x554411ff, 1, 1, 0)
	end

	return self
end


return function ()
	return function (world)
		return Debug(world)
	end
end