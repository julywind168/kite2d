local M = {}

local pool = {}
local uid = 0


function M.get_one()
	local id = next(pool)
	if id then
		pool[id] = nil
		return id
	else
		uid = uid + 1
		return tostring(uid)
	end
end


function M.recovery(id)
	pool[id] = true
end


return M