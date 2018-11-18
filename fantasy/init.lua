local core = require "fantasy.core"

local mouse_name = {
	'left',
	'right'
}

local mouse_event = {
	'press',
	'release',
	'move'
}

local key_name = {

	[32] = 'space',
	[48] = '0', [49] = '1', [50] = '2',
	[51] = '3', [52] = '4', [53] = '5',
	[54] = '6', [55] = '7', [56] = '8',
	[57] = '9', 

	[65] = 'a', [66] = 'b', [67] = 'c',
	[68] = 'd', [69] = 'e', [70] = 'f',
	[71] = 'g', [72] = 'h', [73] = 'i',
	[74] = 'j', [75] = 'k', [76] = 'l',
	[77] = 'm', [78] = 'n', [79] = 'o',
	[80] = 'p', [81] = 'q', [82] = 'r',
	[83] = 's', [84] = 't', [85] = 'u',
	[86] = 'v', [87] = 'w', [88] = 'x',
	[89] = 'y', [90] = 'z',

	[262] = 'right',
	[263] = 'left',
	[264] = 'down',
	[265] = 'up'

}

local key_event = {
	'press',
	'release'
}


local fantasy = {}

function fantasy.start(config, callback)
	local cb = {}
	cb.init = assert(callback.init)
	cb.draw = assert(callback.draw)
	cb.update = assert(callback.update)
	
	assert(callback.mouse)
	cb.mouse = function(what, x, y, who)
		return callback.mouse(mouse_event[what], x, y, who and mouse_name[who])
	end

	cb.keyboard = function(key, what)
		key = key_name[key]
		if not key then 
			return
		end
		return callback.keyboard(key, key_event[what])
	end
	cb.pause = assert(callback.pause)
	cb.resume = assert(callback.resume)
	cb.exit = assert(callback.exit)

	core.inject(config, cb)
end



return setmetatable(fantasy, {__index = core})