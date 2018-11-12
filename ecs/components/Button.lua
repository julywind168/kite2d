return function (t)
	local button = {
		type = 'button',
		name = t.name,
		sprite = assert(t.sprite),
		scale = assert(t.scale),
		handle = {},
	}

	local mt = {}

	function mt.on(event, callback)
		button.handle[event] = callback
	end

	return setmetatable(button, {__index = mt})
end