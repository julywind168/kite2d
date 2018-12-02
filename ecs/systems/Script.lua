local function Script(world)

	local scripts = world.g.scripts
	
	local self = {}	

	function self.init()
		for _,s in ipairs(scripts) do
			if s.init then
				s.init()
			end
		end

		for _,s in ipairs(scripts) do
			if s.start then
				s.start()
			end
		end
	end

	function self.update(dt)
		for _,s in ipairs(scripts) do
			if s.update then
				s.update(dt)
			end
		end
	end

	function self.ejoin(e)
		if e.init or e.start or e.update or e.exit then
			table.insert(scripts, e)
		end
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = self[event]
		if f then
			return f(...)
		end
	end})
end


return Script