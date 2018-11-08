fantasy.window = {
	x = 0,
	y = 0,
	width = 1024,
	height = 768,
	title = 'Fantasy',
}


local function set(key, value)
	assert(fantasy.window[key], string.format("window don't have property:%s.", tostring(key)))
	assert(type(fantasy.window[key]) == type(value), string.format("invalid type:%s.", type(value)))
	fantasy.window[key] = value
end


local function get(key)
	return fantasy.window[key]
end


local function window(key, value1, ...)
	if value1 then
		set(key, value1, ...)
	else
		return get(key)
	end
end


return window