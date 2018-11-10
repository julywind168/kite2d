local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


return function()

	local self = {}

	local sprites = {}


	-- 事件处理
	local handler = {}

	function handler.update(dt)
		for _,sp in ipairs(sprites) do
			sp.node.x = sp.node.x + dt*sp.speed.x
			sp.node.y = sp.node.y + dt*sp.speed.y
		end
	end

	function handler.entity_join(e)
		if e.speed then
			table.insert(sprites, e)
		end
	end

	function handler.entity_leave(e)
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handler[event]
		if f then
			return f(...)
		end
	end})
end