local function _foreach(handle, root, e, ...)
	if not e.active then return end

	handle(root, e, ...)

	if e.list then
		local root = {
			x = root.x + e.x,
			y = root.y + e.y,
			sx = root.sx * e.sx,
			sy = root.sy * e.sy,
			rotate = root.rotate + e.rotate
		}
		for _,e in ipairs(e.list) do
			_foreach(handle, root, e, ...)
		end
	end
end


function eye_foreach(handle, entities, ...)
	local root = {x = 0, y = 0, sx = 1, sy = 1, rotate = 0}
	_foreach(handle, root, entities, ...)
end


function foreach(handle, e)
	handle(e)
	if e.list then
		for _,e in ipairs(e.list) do
			foreach(handle, e)
		end
	end
end