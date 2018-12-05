local function Group(e, t)

	local self = {
		group = t or {}
	}

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

	function self.insert(entity)
		table.insert(self.group, entity)
	end

	return self
end

return function (t)
	return function (e)
		return 'group', Group(e, t)
	end
end