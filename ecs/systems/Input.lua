local function in_aabb(aabb, x, y)

	if x < aabb[1].x or x > aabb[4].x then return false end
	if y > aabb[1].y or y < aabb[2].y then return false end
	return true
end


return function (world)
	
	local textfields = {}

	local self = {}

	local handle = {}

	function handle.ejoin(e)
		if e.textfield then
			table.insert(textfields, e)
		end
	end

	function handle._message(char)
		local editing = world.g.editing
		if editing then
			editing.group.find('label').label.text = editing.group.find('label').label.text .. char
		end
	end

	function handle._keyboard(key, what)
		if what == 'press' then
			world.g.keyboard.pressed = key
			return
		end

		if what =='release' then
			world.g.keyboard.pressed = nil
			local e = world.g.editing
			if e then
				return e.textfield.keyboard(key)
			end
		end
	end

	function handle._mouse(what, x, y, who)
		if what == 'move' then return end
		if who == 'right' then return end
		if what == 'press' then return end

		for _,tf in ipairs(textfields) do
			if in_aabb(tf.group.find('mask').node.aabb, x, y) then
				world.g.editing = tf.textfield.active()
				return
			end
		end

		-- clear
		if world.g.editing then
			world.g.editing.textfield.focus()
			world.g.editing = nil
		end
	end
	
	return setmetatable(self, {__call = function (_, event, ...)
		local f = handle[event]
		if f then
			return f(...)
		end
	end})
end