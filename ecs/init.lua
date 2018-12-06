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
			textfields = {},
			moveing = {},
			listener = {
				lmouse = {},	-- mouse down/up click cacel
				rmouse = {},	-- right mouse ...
				client = {},	-- 鼠标 进入/离开 窗口
				watcher = {},	-- mouse enter/leave
				keyboard = {},	-- key donw/up 
				accepter = {}	-- message

			},
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


	local meta = { }
	
	local handle = {}
	
	local flag = {}
	meta.on = function (event, cb)
		-- assert(e.world and e.world[1] ~= 'no world')

		if IN(event, {'mousedown', 'mouseup', 'click', 'cancel'}) and not flag.lmouse then
			table.insert(e.world.g.listener.lmouse, 1, e)
			flag.lmouse = true
		elseif IN(event, {'rmousedown', 'rmouseup', 'rclick', 'rcancel'}) and not flag.rmouse then
			table.insert(e.world.g.listener.rmouse, 1, e)
			flag.rmouse = true
		elseif IN(event, {'mouseenter', 'mouseleave',}) and not flag.watcher then
			table.insert(e.world.g.listener.watcher, 1, e)
			flag.watcher = true
		elseif IN(event, {'keydown', 'keyup'}) and not flag.listen_keyboard then
			table.insert(e.world.g.listener.keyboard, e)
			flag.listen_keyboard = true
		elseif event == 'message' and not flag.accepter then
			table.insert(e.world.g.listener.accepter, e)
			flag.accepter = true
		elseif event == 'm_enter_client' or event == 'm_leave_client' and not flag.mclient then
			table.insert(e.world.g.accepter.mclient, e)
			flag.mclient = true
		end

		local f = handle[event]
		if f then
			handle[event] = function (...)
				f(...)
				cb(...)
			end
		else
			handle[event] = cb
		end
	end
	meta.__call = function (_, event, ...)
		local f = handle[event]
		if f then
			f(...)
		end
	end
	meta.__index = meta
	meta.__newindex = function (_, k, v)
		assert(meta[k] ~= nil, k)
		local old = meta[k]
		meta[k] = v
		local f = handle['set_'..k]
		if f then f(v, old) end
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
					-- if IN(k, {'init', 'start', 'update', 'exit'}) then
					local f1 = meta[k]
					local f2 = v
					meta[k] = function (...)
						f1(...)
						f2(...)
					end
					-- else
					-- 	error('key conflict ' .. tostring(k))
					-- end
				end
			end
		end
		return e
	end

	return setmetatable(e, meta)
end


return ecs