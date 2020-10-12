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


return function (list)
	
	local target, target_rect

	local on = {}

	function on.mouse_press(x, y)
		list.foreach_from_tail(function (mt)
			if mt.touchable then
				local rect = {x = mt.world_x, y = mt.world_y, w = mt.world_width, h = mt.world_height}
				if point_in_rect(x, y, rect) then
					local proxy = mt.proxy
					local f = proxy.touch_began 
					if f then
						f()
					end
					target = mt
					target_rect = rect
					return true
				end
			end
		end)
	end

	-- function on.mouse_move(x, y)
	--
	-- end

	function on.mouse_release(x, y)
		if target then
			local proxy = target.proxy
			local f = proxy.touch_ended
			if f then
				f()
			end

			if point_in_rect(x, y, target_rect) then
				local f = proxy.on_pressed
				if f then
					f()
				end
			else
				local f = proxy.touch_cancel
				if f then
					f()
				end
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