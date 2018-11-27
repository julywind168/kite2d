local function Script(world)

	local list = world.g.script_list
	
	local self = {}	


	local handle = {}

	function handle._init()
		for _,s in ipairs(list) do
			if s.init then
				s.init()
			end
		end

		for _,s in ipairs(list) do
			if s.start then
				s.start()
			end
		end

	end

	function handle._update(dt)
		for _,s in ipairs(list) do
			if s.update then
				s.update(dt)
			end
		end
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handle[event]
		if f then
			return f(...)
		end
	end})
end


return Script