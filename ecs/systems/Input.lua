local graphics = require "fantasy.graphics"
local window = require "fantasy.window"

local function IN(x, y, x1, y1, width, height)
	if x < x1 - width/2 then
		return false
	end
	if x > x1 + width/2 then
		return false
	end

	if y < y1 - height/2 then
		return false
	end

	if y > y1 + height/2 then
		return false
	end

	return true
end


return function()

	local self = {}

	local buttons = {}


	-- 事件处理
	local handler = {}

	function handler.update(dt)
	end

	local tmp_press

	function handler.mouse(what, x, y, who)
		if who == 'right' then return end
		if what == 'move' then return end
		for i=#buttons,1,-1 do
			local btn = buttons[i]
			if IN(x, window.height-y, btn.sprite.x, btn.sprite.y, btn.sprite.width, btn.sprite.height) then
				local cb = btn.handle[what]
				if cb then cb() end
				if what == 'press' then
					tmp_press = btn
					btn.sprite.scalex = btn.sprite.scalex * btn.scale
					btn.sprite.scaley = btn.sprite.scaley * btn.scale
				elseif what == 'release' then
					if btn == tmp_press then
						local cb = btn.handle['click']
						if cb then cb() end
						btn.sprite.scalex = btn.sprite.scalex / btn.scale
						btn.sprite.scaley = btn.sprite.scaley / btn.scale
						tmp_press = nil
					end
				end
				break
			end
		end
		if what == 'release' and tmp_press then
			local cb = tmp_press.handle["cancel"]
			if cb then cb() end
			tmp_press.sprite.scalex = tmp_press.sprite.scalex / tmp_press.scale
			tmp_press.sprite.scaley = tmp_press.sprite.scaley / tmp_press.scale
			tmp_press = nil
		end
	end

	function handler.button_create(btn, e)
		table.insert(buttons, btn)
	end

	function handler.button_destroy(btn, e)
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handler[event]
		if f then
			return f(...)
		end
	end})
end