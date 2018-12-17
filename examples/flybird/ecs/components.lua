-- description
local description = {
	null = {},
	node = 	{'active', 'type'},
	position = {'x', 'y'},
	transform = {'sx', 'sy', 'rotate'},
	rectangle = {'w', 'h', 'ax', 'ay'},
	sprite = {'texname', 'texcoord', 'color'},
	label = {'text', 'fontname', 'fontsize', 'color'},
	filpbook = {'frames', 'pause', 'stop', 'isloop', 'playspeed', 'timec'},
	button = {'scale'},
	move = {'direction', 'speed'},
	textfield = {'background', 'mask', 'label', 'cursor', 'selected'},

	-- 复杂组件
	Nick = {'nick'},
}


function Nick(t)
	return function ()
		return 'nick', {nick = {
			ox = t.ox or 0,
			oy = t.oy or 0,
			text = assert(t.text),
			fontname = t.fontname, 
			fontsize = t.fontsize or 24,
			color = t.color or 0x888888ff
		}}
	end
end


function Textfield(background, mask, label, cursor, selected)
	return function ()
		return 'textfield', {background = background, mask = mask, label = label, cursor = cursor, selected = selected}
	end
end


function Move(direction, speed)
	return function ()
		return 'move', {direction = direction, speed = speed}
	end
end


function Button(scale)
	return function ()
		return 'button', {scale = scale}
	end
end


function Flipbook(frames, current, pause, isloop, playspeed)
	return function ( )
		return  'flipbook', {
			frames = frames,
			current = current or 1,
			pause = pause or false,
			isloop = isloop or false,
			playspeed = playspeed or 1,
			timec = 0
		}
	end
end

function TAG(tag)
	return function ()
		return tag, {}
	end
end

function Node(active, type)
	return function ()
		return 'node', {active = active and true or false, type = type}
	end
end


function Position(x, y)
	return function ()
		return 'position', {x = x, y = y}
	end
end


function Transform(sx, sy, rotate)
	return function ()
		return 'transform', {sx = sx or 1, sy = sy or 1, rotate = rotate or 0}
	end
end


function Rectangle(w, h, ax, ay)
	return function ()
		return 'rectangle', {w = assert(w), h = assert(h), ax = ax or 0.5, ay = ay or 0.5}
	end
end


function Sprite(texname, texcoord, color)
	return function ()
		return 'sprite', {texname = assert(texname), texcoord = texcoord or {0,1, 0,0, 1,0, 1,1}, color = color or 0xffffffff}
	end
end

function Label(text, fontname, fontsize, color)
	return function ()
		return 'label', {text = assert(text), fontname = fontname,  fontsize = fontsize or 24, color = color or 0x888888ff}
	end
end


return description