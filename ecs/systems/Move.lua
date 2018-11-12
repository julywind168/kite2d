local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


return function()

	local self = {}

	local entities = {}


	-- 事件处理
	local handler = {}

	function handler.update(dt)
		for e,speed in pairs(entities) do
			for _,sp in ipairs(e.components) do
				if sp.type == 'sprite' then
					sp.x = sp.x + speed.x*dt
					sp.y = sp.y + speed.y*dt
				end
			end
		end
	end

	function handler.speed_create(speed, e)
		entities[e] = speed
	end

	function handler.speed_destroy(speed, e)
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handler[event]
		if f then
			return f(...)
		end
	end})
end