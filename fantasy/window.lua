local core = require "window.core"

local window = {
	width = nil,
	height = nil,
	title = nil,
	fullscreen = nil,
}

fantasy.window = window
window.__index = window


local set = {}

function set.width(width)
	window.width = width
	core.update_width(width)
end

function set.height(height)
	window.height = height
	core.update_height(height)
end

function set.title(title)
	window.title = title
	core.update_title(title);
end

function set.fullscreen(fullscreen)
	if window.fullscreen ~= fullscreen then
		window.fullscreen = fullscreen
		if fullscreen == true then
			window.width0 = window.width
			window.height0 = window.height
			window.width, window.height = core.fullscreen()
		else
			window.width = window.width0
			window.height = window.height0
			core.cancel_fullscreen(window.width0, window.height0)
		end
	end
end


window.__newindex = function (_, k, v)
	assert(set[k], k)(v)
end



local M = {}

function M.init(win)
	window.width = win.width
	window.height = win.height
	window.width0 = win.width
	window.height0 = win.height0
	window.title = win.title
	window.fullscreen = win.fullscreen or false
end


return setmetatable(M, window)