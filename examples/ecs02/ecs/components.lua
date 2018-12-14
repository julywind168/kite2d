-- description
local D = {
	null = {},
	node = 	{'active', 'type'},
	position = {'x', 'y'},
	transform = {'sx', 'sy', 'rotate'},
	rectangle = {'w', 'h', 'ax', 'ay'},
	sprite = {'texname', 'texcoord', 'color'},
	label = {'text', 'fontsize', 'color'},
	filpbook = {'frames', 'pause', 'stop', 'isloop', 'speed', 'timec'}
}


-- TAG COMPONENT
function Flipbook(frames, current, pause, isloop, speed)
	return function ( )
		return  'flipbook', D.filpbook, {
			frames = frames,
			current = current or 1,
			pause = pause or false,
			isloop = isloop or false,
			speed = speed or 1,
			timec = 0,
		}
	end
end

function TAG(tag)
	return function ()
		return tag, D.null, {}
	end
end

function Node(active, type)
	return function ()
		return 'node', D.node, {active = active and true or false, type = type}
	end
end


function Position(x, y)
	return function ()
		return 'position', D.position, {x = x, y = y}
	end
end


function Transform(sx, sy, rotate)
	return function ()
		return 'transform', D.transform, {sx = sx or 1, sy = sy or 1, rotate = rotate or 0}
	end
end


function Rectangle(w, h, ax, ay)
	return function ()
		return 'rectangle', D.rectangle, {w = assert(w), h = assert(h), ax = ax or 0.5, ay = ay or 0.5}
	end
end


function Sprite(texname, texcoord, color)
	return function ()
		return 'sprite', D.sprite, {texname = assert(texname), texcoord = texcoord or {0,1, 0,0, 1,0, 1,1}, color = color or 0xffffffff}
	end
end

function Label(text, fontsize, color)
	return function ()
		return 'label', D.label, {text = assert(text), fontsize = fontsize or 24, color = color or 0x888888ff}
	end
end