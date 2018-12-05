local fantasy = require "fantasy"

local function in_box(e, x, y)
	-- 左上角的位置
	local px, py				
	px = e.x - e.w * e.ax
	py = e.y + e.h * (1-e.ay)

	if x < px or x > px + e.w then return false end
	if y > py or y < py - e.h then return false end
	return true
end

local function pos_test(list, x, y)
	for _,e in ipairs(list) do
		if in_box(e, x, y) then
			return e
		end
	end
end


return function (world)
	
	local g_mouse = world.g.mouse
	local g_keyboard = world.g.keyboard
	local g_listener = world.g.listener

	local self = {}

	function self.ejoin(e)
	end

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
		else
			g_keyboard.press_time = 0
			g_keyboard.pressed = nil
			g_keyboard.lpressed = nil
		end

		local event if what=='press' then event='keydown' else event='keyup' end
		for _,e in ipairs(g_listener.keyboard) do
			e(event, key)
		end
	end

	function self.message(char)
		for _,e in ipairs(g_listener.accepter) do
			e('message', char)
		end
	end


	local window = fantasy.window
	local camera = fantasy.camera()

	function self.mouse(what, x, y, who)

		-- 转换成世界坐标
		if x and y then
			x = camera.x + x - window.width/2
			y = camera.y + y - window.height/2
		end

		-- mouse enter/leave client
		if what == 'enter' or what == 'leave' then
			local event = 'm_'..what..'_client'
			for _,e in ipairs(g_listener.client) do
				e(event)
			end
			return
		end

		-- mouse enter/leave obj
		if what == 'move' then
			local hover = g_mouse.hover
			local e = pos_test(g_listener.watcher, x, y)
			if e then
				if e ~= hover then
					e('mouseenter')
				end
				g_mouse.hover = e
			end
			if hover and e ~= hover then
				hover('mouseleave')
				if hover == g_mouse.hover then
					g_mouse.hover = nil
				end
			end
			return
		end

		-- 按下/松开/点击事件
		local prefix = '' if who == 'right' then prefix = 'r' end
		if what == 'press' then
			local e = pos_test(g_listener.lmouse, x, y)
			if e then
				g_mouse.pressed = e
				e(prefix..'mousedown')
			end
		else
			local e = pos_test(g_listener.lmouse, x, y)
			if e then
				e(prefix..'mouseup')
				if e == g_mouse.pressed then
					e(prefix..'click')
				end
			end
			local pressed = g_mouse.pressed
			if pressed then
				g_mouse.pressed = nil
				pressed(prefix..'mouseup')
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