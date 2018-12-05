local function Button(e, t)

	local scale = t or 1.2
	local sx, sy

	local self = {}

	function self.init()
		
		sx, sy = e.sx, e.sy

		e.on('mousedown', function ()
			e.sx = sx * scale
			e.sy = sx * scale
		end)

		e.on('moueup', function ()
			e.sx = sx
			e.sy = sy
		end)
	end

	return self
end


return function (t)
	return function (e)
		return 'button', Button(e, t)
	end
end