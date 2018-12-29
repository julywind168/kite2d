local foreach = foreach

local function Animation(world)

	local self = {name='animation'}


	local update = {}

	function update.flipbook(e, dt)
		e.timec = e.timec + dt
		local interval = 0.167/e.playspeed -- play speed max is 10
		if e.timec >= interval then
			e.timec = e.timec - interval
			e.current = e.current + 1
			if e.current > #e.frames then
				e.current = 1
				if e.isloop == false then
					e.timec = 0
					e.stop = true
				end  
			end
		end
	end

	function update.avatar(e, dt)
		local flipbook = e.actions[e.cur_action]
		update.flipbook(flipbook, dt)
	end


	function self.update(dt)
		foreach(function (e)
			local f = e.type and update[e.type]
			if f then
				f(e, dt)
			end
		end, world.scene)
	end

	return self
end

return function (...)
	return function (world, ...)
		return Animation(world, ...)
	end
end