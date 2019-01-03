local core = require "audio.core"


local music = {
	source = core.source(true)
}

local sources = {}
local buffers = {}

local function get_source(id)
	local s = sources[id]
	if s then return s end

	s = core.source()
	sources[id] = s
	return s
end

local function get_buffer(filename)
	local b = buffers[filename]
	if b then return b end

	b = core.buffer(filename)
	buffers[filename] = b

	return b
end


local M = {}


function M.play_music(filename)
	core.play(music.source, get_buffer(filename))
end


function M.play_effect(id, filename)
	core.play(get_source(id), get_buffer(filename))
end

function M._exit()
	
	core.delete_source(music.source)

	for _,source in pairs(sources) do
		core.delete_source(source)
	end

	for _,buffer in pairs(buffers) do
		core.delete_buffer(buffer)
	end
end


return setmetatable(M, {__index = core})