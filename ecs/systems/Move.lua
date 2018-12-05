
return function (world)

	local g_moveing = world.g.moveing


	local self = {}

	function self.ejoin(e)
		if e.components['transform'] and e.components['speed'] then
			table.insert(g_moveing, e)
		end
	end

	function self.update(dt)
		for _,e in ipairs(g_moveing) do
			if e.speed ~= 0 then
				local distance = e.speed * dt
				local append_x = distance * math.cos(e.direction * math.pi/180)
				local append_y = distance * math.sin(e.direction * math.pi/180)

				e.x = e.x + append_x
				e.y = e.y + append_y
			end
		end
	end

	
	return setmetatable(self, {__call = function (_, event, ...)
		local f = self[event]
		if f then
			return f(...)
		end
	end})
end