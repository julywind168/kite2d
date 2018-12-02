local core = require "fantasy.core"
local graphics = require "graphics.core"

local create_sprite = require "fantasy._sprite"
local create_label = require "fantasy._label"


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
-- api

local fantasy = {
	frame = 0,
	fps = 60,
	config = nil,
	window = nil,
	_camera = nil
}


local function create_camera()
	if fantasy._camera then return fantasy._camera end
	
	local self = {
		x = assert(fantasy.config.camera.x),
		y = assert(fantasy.config.camera.y),
		scale = fantasy.config.camera.scale or 1
	}

	local function set(_, k, v)
		self[k] = v
		graphics.update_camera(self.x, self.y, self.scale)		
	end

	local cam = setmetatable({}, {
		__index = self,
		__pairs = function() return pairs(self) end,
		__newindex = set})

	fantasy._camera = cam
	return fantasy._camera
end

function fantasy.start(config, callback)
	
	fantasy.config = config
	fantasy.window = config.window
	-- component
	fantasy.camera = create_camera
	fantasy.sprite = create_sprite
	fantasy.label = create_label

	-- functions
	fantasy.clear = graphics.clear

	-- inject callback
	local cb = {}
	cb.init = assert(callback.init)
	cb.draw = assert(callback.draw)
	cb.update = function (dt)
		fantasy.frame = fantasy.frame + 1
		if fantasy.frame%30 == 0 then
			fantasy.fps = math.floor(1//dt)
		end
		callback.update(dt)
	end
	
	assert(callback.mouse)
	cb.mouse = function(what, x, y, who)
		if y then
			y = fantasy.config.window.height - y
		end
		return callback.mouse(mouse_event[what], x, y, who and mouse_name[who])
	end

	cb.keyboard = function(key, what)
		key = key_name[key]
		if not key then 
			return
		end
		return callback.keyboard(key, key_event[what])
	end

	cb.message = function (code)
		return callback.message(utf8.char(code))
	end

	cb.pause = assert(callback.pause)
	cb.resume = assert(callback.resume)
	cb.exit = assert(callback.exit)

	core.inject(config, cb)
end


return setmetatable(fantasy, {__index = core})