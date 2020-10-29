local core = require "kite.core"
local audio = require "kite.manager.audio"
local timer = require "kite.timer"

local mouse_name = {
	'left',
	'right'
}

local mouse_event = {
	'press',
	'release',
	'move',
	'enter',
	'leave'
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

	[256] = 'escape', [257] = 'enter', [258] = 'tab',
	[259] = 'backspace', [260] = 'insert',[261] = 'delete',

	[290] = 'f1', [291] = 'f2', [292] = 'f3',
	[293] = 'f4', [294] = 'f5', [295] = 'f6',
	[296] = 'f7', [297] = 'f8', [298] = 'f9',
	[299] = 'f10', [300] = 'f11', [301] = 'f12',	

	[340] = 'shift', [341] = 'ctrl', [342] = 'alt',
	[344] = 'shift', [345] = 'ctrl', [346] = 'alt',

	[262] = 'right',
	[263] = 'left',
	[264] = 'down',
	[265] = 'up'
}

local key_event = {
	'press',
	'release'
}


------------------------------------------------------------------
local kite = {}

function kite.fork(f)
	local co = coroutine.create(f)
	coroutine.resume(co)
	return co
end



function kite.start(callback)

	local cb = {}

	cb.draw = function ()
		callback.draw()
	end
	cb.update = function (dt)
		timer._update(dt)
		callback.update(dt)
	end

	cb.mouse = function(what, x, y, who)
		callback.mouse(mouse_event[what], x, y, who and mouse_name[who])
	end

	cb.keyboard = function(what, key)
		key = key_name[key]
		what = key_event[what]
		if not key then return end

		callback.keyboard(what, key)
	end

	cb.textinput = function (code)
		return callback.textinput(utf8.char(code))
	end

	cb.pause = assert(callback.pause)
	cb.resume = assert(callback.resume)
	cb.scroll = assert(callback.scroll)

	cb.resize = function (w, h)
	end

	cb.exit = function ()
		audio.destroy()
		callback.exit()
	end

	core.inject(cb)
end


return setmetatable(kite, {__index = core})