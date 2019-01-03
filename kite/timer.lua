local function id_pool()
	local self = {}
	local pool = {}
	local id = 0

	function self.get_one( )
		local _id, _ = next(pool)
		if _id then
			pool[_id] = nil
			return _id
		else
			id = id + 1
			return tostring(id)
		end
	end

	function self.recovery(id)
		pool[id] = true
	end

	return self
end


local M = {}

local timers = {}
local pool = id_pool()
local pause = false


function M.create(delay, callback, iteration)
	local id = pool.get_one()
	local timer = {
		time = 0,
		count = 0,
		delay = delay/1000,
		callback = callback,
		iteration = iteration or 1,
	}

	timers[id] = timer

	return id
end


function M._update(dt)
	if pause then return end

	for id,timer in pairs(timers) do
		timer.time = timer.time + dt
		if timer.time >= timer.delay then
			timer.time = timer.time - timer.delay
			timer.count = timer.count + 1
			timer.callback(timer.count)
			if timer.iteration > 0 and timer.count == timer.iteration then
				timers[timer] = nil
				pool.recovery(id)
			end			
		end
	end
end


function M.destroy(timer_id)
	pool.recovery(timer_id)
	timers[timer_id] = nil
end


function M.pause()
	pause = true
end


function M.resume()
	pause = false
end


return M