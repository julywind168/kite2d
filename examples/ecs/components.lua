--
-- single component 的属性描述
--
local description = {
	node = {'active', 'type'},
	group = {'list'},
	position = {'x', 'y'},
	scale = {'sx', 'sy'},
	rotate = {'rotate'},
	rectangle = {'w', 'h', 'ax', 'ay'},
	texture = {'texname', 'texcoord', 'color'},
	text = {'text', 'fontname', 'fontsize', 'color'},
	move = {'speed', 'direction'},
	mass = {'mass'},
	simple_dragg = {'draggable', 'locked'},
	simple_button = {'scale', 'touchable', 'uitype'},
	simple_textfield = {'background', 'mask', 'label', 'cursor', 'selected', 'touchable', 'selectable', 'uitype'},
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
	DRAGG = {'node', 'position', 'rectangle', 'simple_dragg'},
	SPRITE = {'node', 'TRANSFORM', 'rectangle', 'texture'},
	LABEL = {'node', 'TRANSFORM', 'rectangle', 'text'},
	MASK = {'SPRITE', 'group'},
	BUTTON = {'SPRITE', 'simple_button'},
	TEXTFIELD = {'node', 'TRANSFORM', 'rectangle', 'smaple_textfield'},
	FLIPBOOK = {'node', 'TRANSFORM', 'rectangle', 'simple_flipbook'},
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
	return {'FLIPBOOK', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'rectangle', 'simple_flipbook'}, {
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
	return {'TEXTFIELD', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'rectangle', 'simple_textfield'}, {
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
		selectable = true,
		touchable = true,
		uitype = 'textfield'
	}
end end


function Button(t) return function ()
	return {'BUTTON', 'SPRITE', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'sprite', 'rectangle', 'texture', 'simplebutton'}, {
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
		color = t.color or 0xffffffff,

		scale = t.scale or 1.2,
		touchable = true,
		uitype = 'button'
	}
end end


function Mask(t) return function()
	return {'MASK', 'SPRITE', 'TRANSFORM', 'node', 'group', 'position', 'scale', 'rotate', 'rectangle', 'texture'}, {
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
	return {'SPRITE', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'rectangle', 'texture'}, {
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
	return {'LABEL', 'TRANSFORM', 'node', 'position', 'scale', 'rotate', 'rectangle', 'text'}, {
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
		color = t.color or 0xffffffff,
		bordersize = t.bordersize or 0,
		bordercolor = t.bordercolor or 0x000000ff
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
function SimpleDragg(t) return function ()
	t = t or {}
	return 'simple_dragg', {draggable = t.draggable ~= false and true or false, locked = t.locked or false}
end end


function SimpleFlipbook(t) return function ( )
	return  'simple_flipbook', {
		frames = t.frames or {},
		current = t.current or 1,
		pause = t.pause or false,
		isloop = t.isloop or false,
		playspeed = t.playspeed or 1,
		timec = 0,
	}
end end


function SimpleTextfield(t) return function ()
	return 'simple_textfield', {
		background = t.background,
		label = t.label,
		mask = t.mask,
		cursor = t.cursor,
		selected = false,
		touchable = true,
		selectable = true,
		uitype = 'textfield',
	}
end end


function SimpleButton(t) return function ()
	return 'simple_button', { scale = t.scale or 1.2, touchable = true, uitype = 'button' }
end end


function Mass(t) return function ()
	return 'mass', { mass = t.mass or 0 }	
end end


function Move(t) return function ()
	return 'move', { speed = t.speed or 0, direction = t.direction or 0 }
end end


function Rectangel(t) return function ()
	return 'rectangle', { w = t.w or 0, h = t.h or 0, ax = t.ax or 0.5, ay = t.ay or 0.5 }
end end


function Text(t) return function ()
	return 'text', {
		text = t.text or '',
		fontname = t.fontname,
		fontsize = t.fontsize or 24,
		color = t.color or 0xffffffff,
		bordersize = t.bordersize or 0,
		bordercolor = t.bordercolor or 0x000000ff
	}
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


return { description, dependence }