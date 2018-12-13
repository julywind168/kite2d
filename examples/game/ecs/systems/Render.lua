local gfx = require "kite.graphics"

return function (world)

	local self = {name='render'}

	function self.draw(e)
		if e.has.sprite then
			gfx.draw(e.texture, e.x, e.y, e.ax, e.ay, e.sx, e.sy, e.rotate, e.color, e.w, e.h)
		else
			gfx.print(e.text, e.size, e.x, e.y, e.ax, e.ay, e.rotate, e.color, e.fontname)
		end
	end

	function self.__filter__(e)
		return e.active and e.has.sprite or e.has.label or false
	end

	return self
end