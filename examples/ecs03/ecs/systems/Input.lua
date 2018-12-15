--[[



]]

local function IN(x, y, e)
	local x2 = e.x - e.ax * e.w * e.sx
	local y2 = e.y - e.ay * e.h * e.sy
	local x4 = x2 + e.w * e.sx
	local y4 = y2 + e.h * e.sy

	if x < x2 or x > x4 then return false end
	if y < y2 or y > y4 then return false end

	return true
end

local function TEST(x, y, entities)
	for _,e in ipairs(entities) do
		if IN(x, y, e) then
			return e
		end
	end
end

local function Input(world, handle)

	local self = {name='input'}

	local function get_buttons()
		return world.get_entities(function (e)
			return e.has['button'] and e.active
		end)
	end

	local pressed = nil

	function self.mousedown(x, y)
		local button = TEST(x, y, get_buttons())
		if button then
			button.sx = button.sx * button.scale
			button.sy = button.sy * button.scale
			pressed = button
		end
	end

	function self.mouseup(x, y)
		local button = TEST(x, y, get_buttons())
		if button and button == pressed then
			button.sx = button.sx / button.scale
			button.sy = button.sy / button.scale
			local f = handle.click and handle.click[button.name]
			if f then
				f()
			end
			pressed = nil
		else
			if pressed then
				pressed.sx = pressed.sx / pressed.scale
				pressed.sy = pressed.sy / pressed.scale
				local f = handle.cancel and handle.cancel[pressed.name]
				if f then
					f()
				end	
				pressed = nil
			end
		end
	end

	function self.keydown(key)
		local f = handle.keydown and handle.keydown[key]
		if f then f() end
	end

	function self.keyup(key)
		local f = handle.keyup and handle.keyup[key]
		if f then f() end
	end

	return self
end

return function (handle)
	return function (world)
		return Input(world, handle)
	end
end