local timer = require "kite.timer"
local abs = math.abs


local function point_in_rect(x, y, rect)
	if abs(x - rect.x) > rect.w/2 then
		return false
	end
	if abs(y - rect.y) > rect.h/2 then
		return false
	end
	return true
end


local function try(o, method)
	local f = o[method]
	if f then
		return f()
	end
end


return function (list, tree)

	local keyboard = tree.keyboard
	
	-- press states
	local target, target_rect
	local target_pos = {}
	local mosue_pos = {}
	local selected, selected_rect

	local tm = timer.create(0.05, function ()
		if selected and selected.editing and keyboard.lpressed["backspace"] then
			local text = selected.node.text
			if #text > 0 then
				selected.update_text(text:sub(1, utf8.offset(text, utf8.len(text))-1))
			end
		end
	end, -1)


	local on = {}

	function on.update(dt)
		for key,time in pairs(keyboard.pressed) do
			time = time + dt
			keyboard.pressed[key] = time
			if time >= 0.3 then
				keyboard.lpressed[key] = true
			end
		end
	end


	function on.textinput(char)
		if selected and selected.type == "textfield" then
			selected.update_text(selected.node.text .. char)
		end
	end


	function on.keyup(key)
		keyboard.pressed[key] = nil 
		keyboard.lpressed[key] = nil

		local textfield = selected and selected.type == "textfield" and selected
		if textfield then
			if key == 'backspace' then
				local text = textfield.node.text
				if #text > 0 then
					textfield.update_text(text:sub(1, utf8.offset(text, utf8.len(text))-1))
				end
				return true
			elseif key == 'enter' then
				try(textfield, "lost_focus")
				selected = nil
				return true
			end
		end
	end


	function on.keydown(key)
		keyboard.pressed[key] = 0
	end


	function on.mouse_press(x, y)
		if selected and not point_in_rect(x, y, selected_rect) then
			try(selected, "lost_focus")
			selected = nil
		end

		list.foreach_from_tail(function (proxy)
			if proxy.touchable then
				local rect = {x = proxy.world_x, y = proxy.world_y, w = proxy.world_width, h = proxy.world_height}
				if point_in_rect(x, y, rect) then
					target = proxy
					target_rect = rect
					target_pos.x = target.node.x
					target_pos.y = target.node.y
					mosue_pos.x = x
					mosue_pos.y = y

					if target ~= selected then
						selected = target
						selected_rect = target_rect
						try(selected, "gained_focus")
					end
					return true
				end
			end
		end)
	end

	function on.mouse_move(x, y)
		if target and target.draggable then
			target.x = target_pos.x + (x - mosue_pos.x)
			target.y = target_pos.y + (y - mosue_pos.y)
			try(target, "dragging")
		end
	end

	function on.mouse_release(x, y)
		if target then
			try(target, "touch_ended")

			if point_in_rect(x, y, target_rect) then
				try(target, "on_pressed")
			else
				try(target, touch_cancel)
			end
			target = nil
			return true
		end
	end


	return function (event, ...)
		local f = on[event]
		if f then
			return f(...)
		end
	end
end