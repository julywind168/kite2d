local function Miss(self)

	local miss = {}

	function self.miss(key, ...)
		local ui = {...}

		for i=1,#ui,2 do
			local e = ui[i]
			local ekey = ui[i+1]
			e[ekey] = self[key]
		end

		table.insert(miss, { value = self[key], key = key, ui = ui })
		return self
	end	

	local function update()
		for _,m in ipairs(miss) do

			local v = self[m.key]
			if v ~= m.value then
				for i=1,#m.ui,2 do
					local e = m.ui[i]
					local ekey = m.ui[i+1]
					e[ekey] = self[m.key]
				end
				m.value = v
			else
				for i=1,#m.ui,2 do
					local e = m.ui[i]
					local ekey = m.ui[i+1]
					local v = e[ekey]
					if v ~= m.value then
						for i=1,#m.ui,2 do
							local e = m.ui[i]
							local ekey = m.ui[i+1]

							e[ekey] = v
						end
						self[m.key] = v
						return
					end
				end
			end
		end
	end

	return setmetatable(self, {__call = update})
end


return Miss