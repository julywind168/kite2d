local core = require "thread.core"
local self_addr = core.self

local PROTO_SEND = 1
local PROTO_CALL = 2
local PROTO_RETURN = 3

local session = 0
local running = true
local task = {}
local created = {}


local M = {}


function M.query(name)
	return created[name]
end


function M.fork(filename, name)

	local address = core.fork(filename)

	local thread = {}

	function thread.call(...)
		session = session + 1
		core.send(address, self_addr, session, PROTO_CALL, ...)
		task[session] = coroutine.running()
		return coroutine.yield()
	end

	function thread.send(...)
		core.send(address, self_addr, 0, PROTO_SEND, ...)
	end

	created[name] = thread

	return thread
end


function M.start(handle, noblock)

	local function dispatch(source, session, prototype, cmd, ...)

		local function ret(...)
			core.send(source, self_addr, session, PROTO_RETURN, ...)
		end

		if not source then
			return
		end

		if prototype == PROTO_SEND then
			local f = assert(handle[cmd], cmd)
			f(...)
		elseif prototype == PROTO_CALL then
			local f = assert(handle[cmd], cmd)
			ret(f(...))
		else
			assert(prototype == PROTO_RETURN)
			local co = task[session]
			coroutine.resume(co, cmd, ...)
		end
	end

	if noblock then
		return function ()
			dispatch(core.receive_noblock(self_addr))
		end
	else
		while running do
			dispatch(core.receive(self_addr))
		end
	end
end


function M.exit()
	running = false
end



return M