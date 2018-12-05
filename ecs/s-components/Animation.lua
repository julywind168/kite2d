--[[
	animation 是多个 flipbook 的组合体, 一个 flipbook 是一个action
]]

local function Animation(e, t)

	local self = {
		actions = assert(t),
		cur_action = t[1],
	}


	local actions = self.actions
	for _,a in ipairs(actions) do
		actions[a.name] = a
	end

	function self.run_action(name)
		e.cur_action = actions[name]
	end

	function self.init()
		for _,e in ipairs(actions) do
			e.init()
		end
		for _,k in ipairs({'x', 'y', 'sx', 'sy', 'angle'}) do
			e.on('set_'..k, function (new, old)
				for _,e in ipairs(actions) do
					e[k] = e[k] + (new - old)
				end
			end)
		end
	end

	function self.update(dt)
		e.cur_action.update(dt)
	end

	function self.draw()
		e.cur_action.draw()
	end

	return self 
end


return function (t)
	return function (e)
		return 'animation', Animation(e, t)
	end
end