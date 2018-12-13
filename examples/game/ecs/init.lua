local ecs = {}


function ecs.world()
	local self = {}
	local entities = {}
	local systems = {}


	function self.add_entity(e)
		table.insert(entities, e)
		return self
	end

	function self.remove_entity(e)
		for i,_e in ipairs(entities) do
			if _e == e then
				table.remove(entities, i)
				return self
			end
		end
	end


	function self.add_system(system)
		table.insert(systems, system(self))
		return self
	end

	function self.remove_system(name)
		for i,system in ipairs(systems) do
			if system.name == name then
				table.remove(systems, i)
				return self
			end
		end
	end

	return setmetatable(self, {__call = function (_, event, ...)
		for _,sys in ipairs(systems) do
			local handle = sys[event]
			if handle then
				for _,e in ipairs(entities) do
					if sys.__filter__(e) then
						handle(e, ...)
					end
				end
			end
		end
	end})
end


function ecs.entity(name)
	local e = {}
	e.name = name or 'unknown'
	e.has = {}
	return e
end


return ecs