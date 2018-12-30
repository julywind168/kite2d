local M = {}

local miss = {}

function M.create(self)
	assert(self and not self.bind and not self.binding and not self._update, tostring(self))

	self.binding = {}

	function self.bind(key, ...)
		local ui = {...}
		for i=1,#ui,2 do
			local t = ui[i]
			local k = ui[i+1]
			t[k] = self[key]
		end
		table.insert(self.binding, { value = self[key], key = key, ui = ui })
		return self
	end

	miss[self] = true

	return self
end


function M.destroy(self)
	miss[self] = nil
end


function M._update()
	for m,_ in pairs(miss) do
		for _,b in ipairs(m.binding) do

			local v = m[b.key]
			if v ~= b.value then
				for i=1,#b.ui,2 do
					local t = b.ui[i]
					local k = b.ui[i+1]
					t[k] = m[b.key]
				end
				b.value = v
			else
				for i=1,#b.ui,2 do
					local t = b.ui[i]
					local k = b.ui[i+1]
					local v = t[k]
					if v ~= b.value then
						for i=1,#b.ui,2 do
							local t = b.ui[i]
							local k = b.ui[i+1]

							t[k] = v
						end
						m[b.key] = v
						return
					end
				end
			end
		end
	end
end



return M