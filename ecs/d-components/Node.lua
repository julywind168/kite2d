--[[
	active, camera 如果不传 默认为 true
]]
local function Node(e, t)
	local self = {
		active = (t.active ~= false) and true or false,
		camera = (t.camera ~= false) and true or false
	}
	return self
end


return function (t)
	return function (e)
		return 'node', Node(e, t or {})
	end
end
