local graphics = require "fantasy.graphics"
local window = require "fantasy.window"


return function()

	local self = {}

	local entities = {}
	local infos = {}


	-- 事件处理
	local handler = {}

	function handler.update(dt)
		
		for e,_ in pairs(entities) do
			for i=#e.components,1,-1 do
				local ani = e.components[i]
				if ani.type == 'animation' then
					if ani.current == #ani.frames and ani.isloop == false then
						-- pass
					elseif ani.pause == true then
						-- pass
					else
						ani.dt = ani.dt + dt
						if ani.dt >= ani.interval then
							ani.frames[ani.current].active = false
							ani.current = ani.current + 1
							ani.dt = ani.dt - ani.interval
							if ani.current > #ani.frames then
								ani.current = 1
							end
							ani.frames[ani.current].active = true
						end
					end			
				end
			end
		end
	end

	function handler.animation_create(ani, e)
		entities[e] = true
	end

	function handler.animation_destroy(ani, e)
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handler[event]
		if f then
			return f(...)
		end
	end})
end