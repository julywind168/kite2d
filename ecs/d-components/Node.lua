local function Node(e, t)
	local self = {
		active = t.active and true or false,
		camera = t.camera and true or false
	}
	return self
end


return function (t)
	return function (e)
		return 'node', Node(e, t or {})
	end
end
