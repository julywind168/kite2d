require "ecs.preload"
local idpool = require "ecs.id"

local ecs = {
	current_world = nil
}
--------------------------------------------------------------------------------------------
-- World
--------------------------------------------------------------------------------------------
function ecs.world(name)

	local self = {
		name = name,
		entities = {},
		systems = {},
		g = {		
			drawers = {},		-- 渲染列表
			scripts = {},		-- 脚本组件列表
			mouse = {x=0, y=0, enterd = false},
			keyboard = { pressed=nil, lpressed=nil },	-- 按下的, 长按中的
			buttons = {},
			textfields = {}
		}		
	}

	function self.add_system(sys, ...)
		system = sys(self, ...)
		table.insert(self.systems, system)
		return self
	end

	function self.remove_system(name)
		for i,sys in ipairs(self.systems) do
			if sys.name == name then
				table.remove(self.systems, i)
				return self
			end
		end
		error('no this system '..tostring(name))
	end

	-- 派发事件
	local function dispatch(...)
		for _,sys in ipairs(self.systems) do
			if sys(...) then
				break
			end
		end
	end
	
	function self.find_entity(name)
		for _,e in ipairs(self.entities) do
			if e.name == name then
				return e
			end
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

--------------------------------------------------------------------------------------------
-- Entity
--------------------------------------------------------------------------------------------
function ecs.entity(name, e)
	e = e or {}
	e.name = name or 'unknown'
	e.id = idpool.get_one()
	e.world = {'no world'}
	e.components = {}

	local meta = { set={}, handle={} }
	meta.on = function (event, cb)
		meta.handle[event] = cb
	end
	meta.__call = function (_, event, ...)
		local f = meta.handle[event]
		if f then
			f(...)
		end
	end
	meta.__index = meta
	meta.__newindex = function (_, k, v)
		assert(meta[k] ~= nil, k)
		meta[k] = v			-- set
		local f = meta.set[k]
		if f then f(v) end
	end
	meta.__add = function (_, com)
		local name, component = com(e)
		assert(not e.components[name], name)
		e.components[name] = true
		table.insert(e.components, name)
		
		if type(component) ~= 'table' then
			assert(not meta[name])
			meta[name] = component
		else
			for k,v in pairs(component) do
				if not meta[k] then
					meta[k] = v
				else
					if IN(k, {'init', 'start', 'update', 'exit'}) then
						local f1 = meta[k]
						local f2 = v
						meta[k] = function ()
							f1()
							f2()
						end
					else
						print(IN(k, {'init', 'start', 'update', 'exit'}), type(k), k=='init')
						error('key conflict ' .. tostring(k))
					end
				end
			end
		end
		return e
	end

	return setmetatable(e, meta)
end


return ecs