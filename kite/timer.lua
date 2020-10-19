local kite = require "kite.core"


local timers = {}

local M = {}


function M.create(delay, callback, iteration, on_end)
    local timer = {
    	active = true,
        delay = delay,
        callback = callback,
        iteration = iteration or 1,
        on_end = on_end,
        count = 0,
        time = 0
    }

    function timer.destroy()
    	timer.active = false
    end

    function timer.pause()
    	timer.paused = true
    end

    function timer.resume()
    	timer.paused = false
    end

    table.insert(timers, timer)

    return timer
end


function M._update(dt)
	for i=#timers, 1, -1 do
	    local timer = timers[i]
	    if not timer.active then
	        table.remove(timers, i)
	    else
	    	if not timer.paused then
	    		timer.time = timer.time + dt
    			while timer.time > timer.delay do
    				timer.count = timer.count + 1
    				timer.time = timer.time - timer.delay
    				timer.callback()

    				if timer.iteration > 0 and timer.iteration == timer.count then
    					if timer.on_end then
    						timer.on_end()
    					end
    					table.remove(timers, i)
    					break
    				end
    			end
	    	end      
	    end
	end
end


return M