local fantasy = require "fantasy"


local function HeroCamera(e, t)

	local self = {
		screen = assert(t.screen),
		limit = t.limit or {}
	}

	local camera	
	local window = fantasy.window
	local screen = self.screen
	local limit = self.limit
	limit.w = limit.w or window.width/2
	limit.h = limit.h or window.height/2

	function self.init()
		camera = fantasy.camera()

		e.on('set_x', function (x, x0)
			if (x - screen[1] <= window.width/2) or (screen[3] - x <= window.width/2) then return end
			if math.abs(x - camera.x) > limit.w/2 then
				camera.x = camera.x + x - x0
			end
		end)

		e.on('set_y', function (y, y0)
			if (y - screen[2] <= window.height/2) or (screen[4] - y <= window.height/2) then return end
			if math.abs(y - camera.y) > limit.h/2 then
				camera.y = camera.y + y - y0
			end
		end)
	end

	return self
end


return function (t)
	return function (e)
		return 'herocamera', HeroCamera(e, t or {})
	end
end