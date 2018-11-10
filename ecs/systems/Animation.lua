local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


return function()

	local self = {}

	local sprites = {}
	local infos = {}


	-- 事件处理
	local handler = {}

	function handler.update(dt)
		for _,sp in ipairs(sprites) do
			local info = infos[sp]
			info.dt = info.dt + dt
			if info.dt >= sp.animation.interval then
				info.dt = info.dt - sp.animation.interval
				info.current = info.current + 1
				if info.current > #sp.animation.frames then
					info.current = 1
				end
				sp('texture', sp.animation.frames[info.current])
			end
		end
	end

	function handler.entity_join(e)
		if e.animation then
			table.insert(sprites, e)
			infos[e] = {dt = 0, current = 1}
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