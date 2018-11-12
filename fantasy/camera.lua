local core = require "camera.core"

local camera = {
	x = nil,
	y = nil
}


fantasy.camera = camera
camera.__index = camera


local set = {}

function set.x(x)
	camera.x = x
	core.update_x(x)
end

function set.y(y)
	camera.y = y
	core.update_y(y)	
end

camera.__newindex = function (_, k, v)
	assert(set[k], k)(v)
end


local M = {}

function M.init(cam)
	camera.x = cam.x
	camera.y = cam.y
end


return setmetatable(M, camera)