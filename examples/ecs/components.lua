--
-- single component 的属性描述
--
local description = {
	node = {'active', 'type'},
	group = {'list'},
	position = {'x', 'y'},
	scale = {'sx', 'sy'},
	rotate = {'rotate'},
	rectangel = {'w', 'h', 'ax', 'ay'},
	texture = {'texname', 'texcoord', 'color'},
	text = {'text', 'fontname', 'fontsize', 'color'},
	move = {'speed', 'direction'},
	mass = {'mass'},
	simple_button = {'scale', 'clickable'},
	simple_textfield = {'background', 'mask', 'label', 'cursor', 'selected', 'clickable', 'selectable'},
	simple_flipbook = {'frames', 'current', 'isloop', 'pause', 'stop', 'playspeed', 'timec'},

	-- system
	mouse = {'pressed', 'x', 'y'},
	keyboard = {'pressed', 'lpressed'},
}

-- 
-- 高层抽象组件(用大写表示)并没有实际属性  依赖于 single component 的集合, 
-- 比如当一个 entity 有了 position, scale, rotate 组件后, 我们自动认为它有了 'TRANSFORM'组件
--
local dependence = {
	TRANSFORM = {'position', 'scale', 'rotate'},
	CAMERA = {'node', 'TRANSFORM'},
	SPRITE = {'node', 'TRANSFORM', 'rectangel', 'texture'},
	LABEL = {'node', 'TRANSFORM', 'rectangel', 'text'},
	MASK = {'SPRITE', 'group'},
	BUTTON = {'SPRITE', 'simple_button'},
	TEXTFIELD = {'node', 'TRANSFORM', 'rectangel', 'smaple_textfield'},
	FLIPBOOK = {'node', 'TRANSFORM', 'rectangel', 'simple_flipbook'},
}



-----------------------------------------------------------------------------------------
-- system component
-----------------------------------------------------------------------------------------
function Keyboard() return function()
	return 'keyboard', {pressed = {}, lpressed = {}}
end end


function Mouse() return function()
	return 'mouse', {pressed = {}, x = 0, y = 0}
end end

-----------------------------------------------------------------------------------------
-- component family
-----------------------------------------------------------------------------------------
function Flipbook(t) return function ()
	return {'FLIPBOOK', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'rectangel', 'simple_flipbook'}, {
		active = t.active ~= false and true or false,
		type = 'flipbook',
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,
		sy = t.sy or 1,
		rotate = t.rotate or 0,
		w = t.w or 0,
		h = t.h or 0,
		ax = t.ax or 0.5,
		ay = t.ay or 0.5,
		
		frames = t.frames or {},
		current = t.current or 1,
		pause = t.pause or false,
		isloop = t.isloop or false,
		playspeed = t.playspeed or 1,
		timec = 0
	}
end end


function Textfield(t) return function()
	return {'TEXTFIELD', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'rectangel', 'simple_textfield'}, {
		active = t.active ~= false and true or false,
		type = 'textfield',
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,
		sy = t.sy or 1,
		rotate = t.rotate or 0,
		w = t.w or 0,
		h = t.h or 0,
		ax = t.ax or 0.5,
		ay = t.ay or 0.5,

		background = t.background,
		label = t.label,
		mask = t.mask,
		cursor = t.cursor,
		selected = false,
		clickable = true,
		selectable = true
	}
end end


function Button(t) return function ()
	return {'BUTTON', 'SPRITE', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'sprite', 'rectangel', 'texture', 'simplebutton'}, {
		active = t.active ~= false and true or false,
		type = 'button',
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,
		sy = t.sy or 1,
		rotate = t.rotate or 0,
		w = t.w or 0,
		h = t.h or 0,
		ax = t.ax or 0.5,
		ay = t.ay or 0.5,
		texname = t.texname or 'resource/white.png',
		texcoord = t.texcoord or {0,1, 0,0, 1,0, 1,1},
		color = t.color or 0xffffffff,
		scale = t.scale or 1.2,
		clickable = true,
	}
end end


function Mask(t) return function()
	return {'MASK', 'SPRITE', 'TRANSFORM', 'node', 'group', 'position', 'scale', 'rotate', 'rectangel', 'texture'}, {
		active = t.active ~= false and true or false,
		type = 'mask',
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,
		sy = t.sy or 1,
		rotate = t.rotate or 0,
		w = t.w or 0,
		h = t.h or 0,
		ax = t.ax or 0.5,
		ay = t.ay or 0.5,
		texname = t.texname or 'resource/white.png',
		texcoord = t.texcoord or {0,1, 0,0, 1,0, 1,1},
		color = t.color or 0xffffffff,
		list = t.list or {}
	}
end end


function Sprite(t) return function ()
	return {'SPRITE', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'rectangel', 'texture'}, {
		active = t.active ~= false and true or false,
		type = 'sprite',
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,
		sy = t.sy or 1,
		rotate = t.rotate or 0,
		w = t.w or 0,
		h = t.h or 0,
		ax = t.ax or 0.5,
		ay = t.ay or 0.5,
		texname = t.texname or 'resource/white.png',
		texcoord = t.texcoord or {0,1, 0,0, 1,0, 1,1},
		color = t.color or 0xffffffff
	}
end end


function Label(t) return function()
	return {'LABEL', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'rectangel', 'text'}, {
		active = t.active ~= false and true or false,
		type = 'label',
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,
		sy = t.sy or 1,
		rotate = t.rotate or 0,
		w = t.w or 0,
		h = t.h or 0,
		ax = t.ax or 0.5,
		ay = t.ay or 0.5,
		text = t.text or '',
		fontname = t.fontname,
		fontsize = t.fontsize or 24,
		color = t.color or 0xffffffff
	}
end end


function Camera(t) return function()
	return {'CAMERA', 'node', 'TRANSFORM', 'position', 'scale', 'rotate'}, {
		active = t.active ~= false and true or false,
		type = 'camera',
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,
		sy = t.sy or 1,
		rotate = t.rotate or 0,
	}
end end


function Transform(t) return function()
	return { 'TRANSFORM', 'position', 'scale', 'rotate' }, {
		x = t.x or 0,
		y = t.y or 0,
		sx = t.sx or 1,
		sy = t.sy or 1,
		rotate = t.rotate or 0,
	}
end end

-----------------------------------------------------------------------------------------
-- single component
-----------------------------------------------------------------------------------------
function SimpleFlipbook(t) return function ( )
	return  'simple_flipbook', {
		frames = t.frames or {},
		current = t.current or 1,
		pause = t.pause or false,
		isloop = t.isloop or false,
		playspeed = t.playspeed or 1,
		timec = 0
	}
end end


function SimpleTextfield(t) return function ()
	return 'simple_textfield', {
		background = t.background,
		label = t.label,
		mask = t.mask,
		cursor = t.cursor,
		selected = false,
		clickable = true,
		selectable = true
	}
end end


function SimpleButton(t) return function ()
	return 'simple_button', { scale = t.scale or 1.2, clickable = true }
end end


function Mass(t) return function ()
	return 'mass', { mass = t.mass or 0 }	
end end


function Move(t) return function ()
	return 'move', { speed = t.speed or 0, direction = t.direction or 0 }
end end


function Rectangel(t) return function ()
	return 'rectangel', { w = t.w or 0, h = t.h or 0, ax = t.ax or 0.5, ay = t.ay or 0.5 }
end end


function Text(t) return function ()
	return 'text', { text = t.text or '', fontname = t.fontname, fontsize = t.fontsize or 24, color = t.color or 0xffffffff }
end end


function Texture(t) return function ()
	return 'texture', {
		texname = t.texname or 'resource/white.png',
		texcoord = t.texcoord or {0,1, 0,0, 1,0, 1,1},
		color = t.color or 0xffffffff
	}
end end


function Rotate(t) return function ()
	return 'rotate', { rotate = t.rotate or 0 }
end end


function Scale(t) return function ()
	return 'scale', { sx = t.sx or 1, t.sy or 1 }
end end


function Position(t) return function ()
	return 'position', { x = t.x or 0, y = t.y or 0}
end end


function Group(t) return function ()
	return 'group', { list = t and t.list or {} }
end end


function Node(t) return function ()
	return 'node', {active = t.active ~= false and true or false, type = t.type or 'nil' }
end end


return description, dependence