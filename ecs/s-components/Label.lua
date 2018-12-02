local ecs = require "ecs"
local graphics = require "ecs.graphics"
local util = require "ecs.util.sprite"


local function Label(e, t)
	local self = {
		active = (t.active ~= false) and true or false,
		camera = (t.camera ~= false) and true or false,
		color = t.color or 0xffffffff,

		fontname = assert(t.fontname),
		fontsize = t.fontsize or 24,
		text = t.text or ''
	}

	local font, scale, chars

	function self.init()
		assert(e.components['transform'] and e.components['rectangle'])

		font = graphics.font(e.fontname)
		scale = e.fontsize/font.size
		chars = font.chars(e.text)
		e.w = graphics.chars_length(chars, scale)
		e.h = e.fontsize

		-- hook
		local after = getmetatable(e)
		
		function after.set.text()
			chars = font.chars(e.text)
			e.w = graphics.chars_length(chars, scale)
		end
	end

	function self.draw()
		if e.active then
			graphics.set_tx_color(e.color)
			graphics.draw_text(e.x - e.ax * e.w, e.y - (e.ay - 0.5) * e.h, scale, chars, e.angle, e.camera)
		end
	end

	return self
end


return function (t)
	return function (e)
		return 'label', Label(e, t or {})
	end
end