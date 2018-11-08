local c = require "system.core"

fantasy.system = {
	volume = 1,
	display = {
		width = 0,
		height = 0,
	}
}

do
	fantasy.system.display = c.display()[1]

end




	

local function set(key, value, ...)
	assert(fantasy.system[key], string.format("system don't have property:%s.", tostring(key)))
	assert(type(fantasy.system[key]) == type(value), string.format("invalid type:%s.", type(value)))
	fantasy.system[key] = value

	-- do something
	-- pass
end


local function get(key)
	return fantasy.system[key]
end




local function system(key, value1, ...)
	if value1 then
		set(key, value1, ...)
	else
		return get(key)
	end
end


return system
