local gfx = require "kite.graphics"

return function ()

	local self = {name='render'}

	function self.draw(e)
		if e.has.sprite then
			gfx.draw(e.texname, e.x, e.y, e.ax, e.ay, e.sx, e.sy, e.rotate, e.color, e.w, e.h, e.texcoord)
		else
			e.w = gfx.print(e.text, e.fontsize, e.x, e.y, e.color, e.ax, e.ay, e.rotate, e.fontname)
		end
	end

	function self.__filter__(e)
		return e.active and e.has.sprite or e.has.label or false
	end

	return self
end