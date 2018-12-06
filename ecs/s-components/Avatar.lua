--[[
	纸娃娃组件, Animation 的加强版
	一个 ani 是多个 action(flipbook) 组成, 一个action 有多帧, 每帧有一个对应的group组(衣服,帽子,...)

	local e = {}
		+ Node{}
		+ Tras{}
		+ Animation{}
		+ Avatar{
			walk_down = {
				e() + Node() + Group(),
				e() + Node() + Group(),
				e() + Node() + Group(),
				e() + Node() + Group(),
			},
			walk_up = {
				e() + Node() + Group(),
				e() + Node() + Group(),
				e() + Node() + Group(),
				e() + Node() + Group(),
			},
		}
]]

local ecs = require "ecs"

local function Avatar(e, t)
	
	local self = {
		avatar = assert(t),
		cur_frame_face = t[e.cur_action.name][1],
	}

	local avatar = self.avatar

	for _,groups in pairs(avatar) do
		for _,g in ipairs(groups) do
			ecs.current_world.add_entity(g)
		end
	end

	function self.init()
		for name,faces in pairs(avatar) do
			for i,face in ipairs(faces) do
				face.active = (face == e.cur_frame_face)
			end
		end

		for _,k in ipairs({'x', 'y', 'sx', 'sy', 'angle'}) do
			e.on('set_'..k, function (v)
				for _,groups in pairs(avatar) do
					for _,g in ipairs(groups) do
						g[k] = v
					end
				end
			end)
		end

		-- hook set cur_frame
		for _,action in ipairs(e.actions) do
			action.on('set_cur_frame', function (frame)
				assert(action == e.cur_action)
				e.cur_frame_face.active = false
				e.cur_frame_face = avatar[e.cur_action.name][frame]
				e.cur_frame_face.active = true
			end)
		end
	end

	return self
end

return function (t)
	return function (e)
		return 'avatar', Avatar(e, t)
	end
end