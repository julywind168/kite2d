local window = {
	width = nil,
	height = nil,
	title = nil,
}

fantasy.window = window
window.__index = window
window.__newindex = function (_, k, v)
	-- body
end



local M = {}

function M.init(width, height, title)
	window.width = width
	window.height = height
	window.title = title
end


return setmetatable(M, window)