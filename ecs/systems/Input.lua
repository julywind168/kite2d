local function in_aabb(aabb, x, y)
	if x < aabb[1].x or x > aabb[4].x then return false end
	if y > aabb[1].y or y < aabb[2].y then return false end
	return true
end


return function (world)
	
	local g = world.g
	local g_mouse = world.g.mouse
	local g_keyboard = world.g.keyboard
	local buttons = g.buttons
	local textfields = g.textfields

	local self = {}

	function self.ejoin(e)
		if e.components['textfield'] then
			table.insert(textfields, e)
		elseif e.components['button'] then
			table.insert(buttons, e)
		end
	end

	function self.message(char)
		local e = world.g.active_input
		if e then
			e('message', char)
		end
	end

	--[[
		按下持续0.3s 才会设置 world.g.keyboard.pressed
	]]

	function self.update(dt)
		if g_keyboard.pressed then
			g_keyboard.press_time = g_keyboard.press_time + dt
			if g_keyboard.press_time > 0.3 then
				g_keyboard.lpressed = g_keyboard.pressed
			end
		end
	end

	function self.keyboard(key, what)
		if what == 'press' then
			g_keyboard.pressed = key
			g_keyboard.press_time = 0
			return
		end

		if what =='release' then
			g_keyboard.press_time = 0
			g_keyboard.pressed = nil
			g_keyboard.lpressed = nil
			
			local e = world.g.active_input
			if e then
				return e('key_release', key)
			end
		end
	end

	function self.mouse(what, x, y, who)
		if what == 'enter' then
			g_mouse.entered = true
			return
		elseif what == 'leave' then
			g_mouse.entered = false
			return
		end
		g.mouse.x = x
		g.mouse.y = y

		if what == 'move' then return end
		if who == 'right' then return end

		if what == 'press' then
			for _,e in ipairs(buttons) do
				if in_aabb(e.aabb, x, y) then
					g.pressed_btn = e
					e('_press')
					return
				end
			end
		else
			--[[
				textfield
			]]
			for _,tf in ipairs(textfields) do
				if in_aabb(tf.mask.aabb, x, y) then
					if g.active_input == tf then
						return
					end
					if g.active_input then
						g.active_input('focus')
					end
					tf('active')
					g.active_input = tf
					return
				end
			end

			if g.active_input then
				g.active_input('focus')
				g.active_input = nil
			end

			--[[
				button
			]]
			for _,e in ipairs(buttons) do
				if in_aabb(e.aabb, x, y) and e == g.pressed_btn then
					g.pressed_btn = nil
					e('_release')
					e('click')
					return
				end
			end

			if g.pressed_btn then
				g.pressed_btn('_release')
				g.pressed_btn('cancel')
				g.pressed_btn = nil	
			end
		end
	end
	
	return setmetatable(self, {__call = function (_, event, ...)
		local f = self[event]
		if f then
			return f(...)
		end
	end})
end