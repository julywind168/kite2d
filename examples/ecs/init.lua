require 'ecs.systems.util'

local description, dependence = table.unpack(require 'ecs.components')


local ecs = {}


function ecs.world(entities)

	local self = {}
	
	self.entities = assert(entities)
	self.systems = {}	

	local function find_e(e, name)
		if e.name == name then
			return e 
		end
		if e.list then
			for _,_e in ipairs(e.list) do
				local e = find_e(_e, name)
				if e then return e end
			end
		end
	end

	function self.find_entity(name)
		return find_e(self.entities, name)
	end

	function self.add_entity(e)
		table.insert(self.canvas.list, e)
		return self
	end

	function self.add_entitys(es)
		for _,e in ipairs(es) do
			table.insert(self.canvas.list, e)
		end
		return self
	end

	function self.remove_entity(e)
	end


	function self.add_system(system)
		table.insert(self.systems, system(self))
		return self
	end

	function self.remove_system(name)
		for i,system in ipairs(self.systems) do
			if system.name == name then
				table.remove(systems, i)
				return self
			end
		end
	end

	return setmetatable(self, {__call = function (_, event, ...)
		for _,sys in ipairs(self.systems) do
			local handle = sys[event]
			if handle then
				handle(...)
			end
		end
	end})
end


local function match(condition, components)
	for _,name in ipairs(condition) do
		if not components[name] then
			return false
		end
	end
	return true
end

function ecs.entity(name, e)
	e = e or {}
	e.name = name or 'unknown'
	e.has = {}

	return setmetatable(e, {__add = function (_, f)
		local name, data = f()

		if type(name) == 'table' then
			for _,nm in ipairs(name) do
				assert(not e.has[nm], 'repeat component '..nm)
				e.has[nm] = true
			end
		else
			assert(not e.has[name], 'repeat component '..name)		
			e.has[name] = true
		end
		
		-- 添加抽象组件
		for abstract,condition in pairs(dependence) do
			if match(condition, e.has) then
				e.has[abstract] = true
			end	
		end

		for k,v in pairs(data) do
			assert(not e[k], 'repeat key'..k)
			e[k] = v
		end
		return e
	end, __sub = function (_, name)
		assert(e.has[name], 'no component '..tostring(name))
		local desc = description[name]
		if desc then
			for _,key in ipairs(desc) do
				e[key] = nil
			end
		end
		e.has[name] = nil
	end})
end


return ecs