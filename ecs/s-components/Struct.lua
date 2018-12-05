local function Struct(e, t)
	local self = {}
	
	for _,e in ipairs(t) do
		self[e.name] = e
	end

	function self.init()
		assert(e.components['transform'])

		for _,k in ipairs({'x', 'y', 'sx', 'sy', 'angle'}) do
			e.on('set_'..k, function (new, old)
				for _,e in ipairs(self.group) do
					e[k] = e[k] + (new - old)
				end
			end)
		end
	end

	return self
end


return function (t)
	return function (e)
		return 'struct', Struct(e, t)
	end
end