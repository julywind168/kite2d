local kite = require "kite.core"
local core = require "audio.core"

local music_loop = true
local music = core.source(true)
local effect = core.source(false)
local buffer = {}


local function query_buffer(filename)
	if not buffer[filename] then
		buffer[filename] = core.buffer(kite.gamedir.."/"..filename)
	end
	return buffer[filename]
end


local M = {}


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


function M.destroy()
	core.delete_source(music)
	core.delete_source(effect)

	for _,buf in pairs(buffer) do
		core.delete_buffer(buf)
	end
end


return M