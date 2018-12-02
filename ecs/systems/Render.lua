local graphics = require "ecs.graphics"

local function Render(world, color)

	local color = color or 0x000000ff
	local drawers = world.g.drawers

	local self = {}

	function self.draw()
		graphics.clear(color)
		for _,e in ipairs(drawers) do
			e.draw()
		end
	end

	function self.ejoin(e)
		if e.draw then
			table.insert(drawers, e)
		end
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = self[event]
		if f then
			return f(...)
		end
	end})
end


return Render