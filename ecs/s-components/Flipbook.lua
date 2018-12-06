local function Flipbook(e, t)
	local self = {
		frames = t.frames,
		interval = t.interval,
		isloop = t.isloop,
		pause = t.pause or false,
		cur_frame = t.cur_frame or 1
	}

	function self.init()
		assert(e.components['transform'])

		for _,e in ipairs(self.frames) do
			e.init()
			e.active = true
		end

		for _,k in ipairs({'x', 'y', 'sx', 'sy', 'angle'}) do
			e.on('set_'..k, function (new, old)
				for _,e in ipairs(self.frames) do
					e[k] = e[k] + (new - old)
				end
			end)
		end
	end

	local delay = 0	
	local frames = self.frames
	local tmp_frame

	function self.update(dt)
		if e.cur_frame == #frames and e.isloop == false then
			e('action_done')
		else
			if not e.pause then
				delay = delay + dt
				if delay >= e.interval then
					tmp_frame = e.cur_frame + 1
					delay = delay - e.interval
					if tmp_frame > #frames then
						e('action_done')
						tmp_frame = 1
					end
					e.cur_frame = tmp_frame
				end
			end
		end
	end

	function self.draw()
		if e.active then
			frames[e.cur_frame].draw()
		end
	end

	return self
end


return function (t)
	return function (e)
		return 'flipbook', Flipbook(e, t)
	end
end