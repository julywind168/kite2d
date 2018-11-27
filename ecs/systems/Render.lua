local graphics = require "ecs.graphics"

local function Render(world, color)

	local color = color or 0x000000ff	
	local list = world.g.render_list


	local self = {}	

	
	local handle = {}

	function handle._draw()
		graphics.clear(color)
		for _,e in ipairs(list) do
			e.draw()
		end
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handle[event]
		if f then
			return f(...)
		end
	end})
end


return Render