local ecs = require "ecs"
local graphics = require "ecs.graphics"
local function TextField(e, t)
	local self = {
		active = (t.active ~= false) and true or false,
		camera = t.camera and true or false
	}

	local g = ecs.current_world.g
	local background, mask, label, cursor

	function self.init()
		assert(e.components['struct'])
		background = assert(e.background)
		mask = assert(e.mask)
		label = assert(e.label)
		cursor = assert(e.cursor)

		assert(background.components['sprite'] and mask.components['sprite']
			and cursor.components['sprite'] and label.components['label'])

		background.x = e.x
		background.y = e.y
		background.w = e.w
		background.h = e.h
		background.ax = e.ax
		background.ay = e.ay
		background.camera = e.camera

		mask.x = e.x - 2
		mask.y = e.y
		mask.w = e.w - 8
		mask.h = e.h - 4
		mask.ax = e.ax
		mask.ay = e.ay
		mask.camera = e.camera

		label.ax = 0
		label.ay = e.ay
		label.x = mask.x - mask.w * mask.ax
		label.y = e.y - 6
		label.camera = e.camera

		cursor.x = label.x
		cursor.y = e.y
		cursor.w = 1
		cursor.h = math.floor(e.h * 32/48)
		cursor.ax = 0
		cursor.ay = e.ay
		cursor.camera = e.camera
		cursor.active = false

		background.init()
		mask.init()
		label.init()
		cursor.init()

		e.on('active', function ()
			cursor.x = label.x + (1-label.ax) * label.w + 2
			cursor.active = true
		end)

		e.on('focus', function ()
			cursor.active = false
		end)

		e.on('key_release', function (key)
			if key == 'backspace' then
				local len = #label.text 
				if len > 0 then
					label.text = label.text:sub(1, len -1)
				end
			end
		end)

		e.on('message', function (char)
			label.text = label.text..char
		end)

		local after = getmetatable(label)
		local label_set_text = after.set.text

		function after.set.text()
			label_set_text()
			if label.w <= mask.w and label.ax ~= 0 then
				label.ax = 0
				label.x = mask.x - mask.w * mask.ax
			elseif label.w > mask.w and label.ax ~= 1 then
				label.ax = 1
				label.x = mask.x + mask.w * mask.ax
			end
			cursor.x = label.x + (1-label.ax) * label.w + 2			
		end
	end

	local delay1, delay2 = 0, 0
	function self.update(dt)
		if g.active_input ~= e then return end

		delay1 = delay1 + dt
		if delay1 > 0.5 then
			delay1 = 0
			cursor.active = not cursor.active
		end

		if g.keyboard.lpressed == 'backspace' then
			delay2 = delay2 + dt
			if delay2 > 0.05 then
				delay2 = 0
				local len = #label.text 
				if len > 0 then
					label.text = label.text:sub(1, len -1)
				end
			end
		end
	end

	function self.draw()
		if e.active then
			background.draw()
			graphics.start_stencil()
			mask.draw()
			graphics.stop_stencil()
			label.draw()
			graphics.clear_stencil()
			cursor.draw()
		end
	end

	return self
end

return function (t)
	return function (e)
		return 'textfield', TextField(e, t or {})
	end
end