local camera = {
	x = nil,
	y = nil
}

fantasy.camera = camera
camera.__index = camera
camera.__newindex = function (_, k, v)
	-- body
end



local M = {}

function M.init(x,y)
	camera.x = x
	camera.y = y
end


return setmetatable(M, camera)