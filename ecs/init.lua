local idpool = require "ecs.idpool"

local ecs = {
	worlds = {}
}



-- new a world
-- call is mean send event
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

	function self.add_system(sys)
		table.insert(self.systems, sys)
	end
	
	function self.join(e)
		dispatch('entity_join', e)
	end

	function self.leave(e)
		dispatch('entity_leave', e)
	end

	ecs.worlds[name] = self

	return setmetatable(self, {__call = function (_, event, ...)
		dispatch(event, ...)
	end})
end


-- new a entity
--[[
	local hero = ecs.entity({}, 'hero')
	hero('add', Node, {x=0,y=0})
]]
function ecs.entity(e, name)

	e = e or {}

	local meta = {
		id = idpool.get_one(),
		name = name,
		world = nil,
		add = function (comp, ...)
			local node_name, node = comp(e, ...)
			assert(e[node_name] == nil, 'already has this component: '..tostring(node_name))
			e[node_name] = node
		end
	}

	return setmetatable(e, {__call = function (_, k, v, ...) 
		local what = meta[k]
		if what and type(what) == 'function' then
			return what(v, ...)
		else
			if v then
				meta[k] = v
			else
				return what
			end
		end
	end})
end


return ecs