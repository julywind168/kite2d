return function (e, t)

	local t = t or {}
	local self = {
		x = t.x or 0,
		y = t.y or 0,
		list = t.list or {}
	}

	function self.init()

		-- hook group
		local set = {}

		function set.x(x)
			local offset = x - self.x
			self.x = x
			for _,e in ipairs(self.list) do
				if e.node then
					e.node.x = e.node.x + offset
				elseif e.group then
					e.group.x = e.group.x + offset
				end
			end
		end

		function set.y(y)
			local offset = y - self.y
			self.y = y
			for _,e in ipairs(self.list) do
				if e.node then
					e.node.y = e.node.y + offset
				elseif e.group then
					e.group.y = e.group.y + offset
				end
			end
		end

		e.group = setmetatable({}, {
				__index = self,
				__pairs = function () return pairs(self) end,
				__newindex = function (_,k,v) set[k](v) end
			})
	end

	function self.add(e)
		assert(e.node or e.group)
		table.insert(self.list, e)
	end

	function self.find(name)
		for _,e in ipairs(self.list) do
			if e.name == name then
				return e
			end
		end

		for _,e in ipairs(self.list) do
			if e[name] then
				return e
			end
		end

	end

	return 'group', self
end