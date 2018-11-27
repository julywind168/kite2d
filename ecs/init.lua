local idpool = require "ecs.id"

local ecs = {
	current_world = nil
}

function ecs.world(name)

	local self = {
		name = name,
		entities = {},
		systems = {},
		g = {		-- 世界状态(比如渲染列表)
			render_list = {},
			script_list = {},
			keyboard = { pressed=nil },
		}		
	}

	function self.add_system(sys, ...)
		system = sys(self, ...)
		table.insert(self.systems, system)
		return self
	end

	function self.remove_system(sys_name)
		for i,sys in ipairs(self.systems) do
			if sys.name == sys_name then
				table.remove(self.systems, i)
				return self
			end
		end
		error('no this system '..tostring(sys_name))
	end

	-- 派发事件
	local function dispatch(...)
		for _,sys in ipairs(self.systems) do
			sys(...)
		end
	end

	function self.add_entity(e)
		e.world = self
		table.insert(self.entities, e)
		dispatch('ejoin', e)
		return e
	end

	function self.remove_entity(e)
		e.world = nil
		for i,_e in ipairs(self.entities) do
			if _e == e then
				table.remove(self.entities, i)
				break
			end
		end
		dispatch('eleave', e)
	end


	ecs.current_world = self

	return setmetatable(self, {__call = function(_, ...) dispatch(...) end})
end


function ecs.entity(name, e)
	e = e or {}
	e.name = name
	e.id = idpool.get_one()
	e.world = nil

	function e.add(com, ...)
		local name, component = com(e, ...)
		assert(e[name] == nil, 'repeat component '..tostring(name))
		e[name] = component

		return e
	end

	function e.add_script(scr, ...)
		local name, component = scr(e, ...)
		assert(e[name] == nil, 'repeat component '..tostring(name))
		e[name] = component
		table.insert(ecs.current_world.g.script_list, component)
		return e
	end

	function e.remove(name)
		e[name] = nil
		return e
	end

	return e
end


return ecs