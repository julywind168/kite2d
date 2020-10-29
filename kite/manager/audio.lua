local kite = require "kite.core"
local core = require "audio.core"
local sharetable = require "sharetable.core"

local _sources = sharetable.init("_sources")
local _buffers = sharetable.init("_buffers")


local function gen_soucre(...)
	local source = core.source(...)
	table.insert(_sources, source)
	return source
end

local function gen_buffer(...)
	local buffer = core.buffer(...)
	table.insert(_buffers, buffer)
	return buffer
end

-----------------------------------------------------------------

local music_loop = true
local music, effect
local buffer = {}


local function query_buffer(filename)
	if not buffer[filename] then
		buffer[filename] = gen_buffer(kite.gamedir.."/"..filename)
	end
	return buffer[filename]
end


local M = {}

function M.init()
	music = gen_soucre(true)
	effect = gen_soucre(false)
	return M
end


function M.preload(t)
	for _,filename in ipairs(t) do
		query_buffer(filename)
	end
end


function M.stop_music()
	core.source_stop(music)
end


function M.pause_music()
	core.source_pause(music)
end


function M.rewind_music()
	core.source_rewind(music)
end


function M.play_music(filename, is_loop)
	if is_loop == nil then
		is_loop = true
	end

	if is_loop ~= music_loop then
		music_loop = is_loop
		core.source_set_loop(music, is_loop)
	end

	core.play(music, query_buffer(filename))
end


function M.play_effect(filename)
	core.play(effect, query_buffer(filename))
end

-- call by main thread
function M.destroy()
	for _,source in ipairs(_sources) do
		core.delete_source(source)
	end

	for _,buffer in pairs(_buffers) do
		core.delete_buffer(buffer)
	end
end


return M