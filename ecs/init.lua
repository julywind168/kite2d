local idpool = require "ecs.idpool"
local flag = require "ecs.flag"

local ecs = {
	worlds = {}
}


function ecs.world(name)
	local self = {
		name = name,
		entities = {},
		systems = {},
	}

	local function dispatch(event, ...)
		for _,sys in ipairs(self.systems) do
			sys(event, ...)
		end
	end

	function self.add_system(create_sys, ...)
		table.insert(self.systems, create_sys(...))
	end

	function self.remove_system(system)
		for _,sys in ipairs(self.systems) do
			if sys == system then
				table.remove(self.systems, i)
				break
			end
		end
	end
	
	function self.add_entity(e)
		table.insert(self.entities, e)
		e.world = self.name
		dispatch('e_join', e)
		for _,com in ipairs(e.components) do
			dispatch(com.type..'_create', com, e)
		end
		return e
	end

	function self.remove_entity(e)
		dispatch('e_leave', e)
		for _,com in ipairs(e.components) do
			dispatch(com.type..'_destroy', com, e)
		end
	end

	ecs.worlds[name] = self

	return setmetatable(self, {__call = function (_, event, ...)
		dispatch(event, ...)
	end})
end


function ecs.entity(name, e)
	e = e or {}
	e.id = idpool.get_one()
	e.name = name
	e.world = nil

	e.components = {}
	e.named = {}

	function e.add(com)
		table.insert(e.components, com)
		if com.name then
			e.named[com.name] = com
		end

		local world = e.world and ecs.worlds[e.world]
		if world then
			world(com.type..'_create', com)
		end
		return e
	end

	function e.find(com_name)
		return e.named[com_name]
	end

	return e
end


return ecs