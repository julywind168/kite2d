local sin = math.sin
local cos = math.cos
local PI = math.pi


local util = {}



function util.rotate(x0, y0, a, x1, y1)
	a = a * PI/180
	local x = (x1 - x0)*cos(a) - (y1 - y0)*sin(a) + x0
	local y = (x1 - x0)*sin(a) + (y1 - y0)*cos(a) + y0
	return x, y
end






return util