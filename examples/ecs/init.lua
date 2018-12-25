require 'ecs.systems.util'

local description, dependence = table.unpack(require 'ecs.components')


local ecs = {}


-- scene is a entity group (tree)
function ecs.world(scene, handle)

	local self = {}
	
	self.scene = scene
	self.handle = handle
	self.systems = {}
	self.keyboard = {pressed = {}, lpressed = {}}
	self.mouse = {pressed = {}, x = 0, y = 0}

	local watchers = {}

	local function on(event, ...)
		local f = self.handle and self.handle[event]
		if f then f(...) end
	end

	-- 切换场景
	function self.switch(new_scene, new_handle, effect)
		local old = self.scene
		
		if effect then
			effect(self, old, new_scene, new_handle)
		else
			self.scene = new_scene
			self.handle = new_handle		
		end
	end

	function self.set_scene(scene)
		self.scene = scene
		return self
	end

	function self.set_handle(handle)
		self.handle = handle
		return self
	end

	function self.watch(cond, callback, times)
		local w = { cond = cond, callback = callback, times = times or 1 }
		local tail = w

		function w.join(cond, callback, times)
			local w1 = { cond = cond, callback = callback, times = times or 1 }
			tail.next = w1
			tail = w1
		end

		watchers[w] = true
		return w
	end


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
		return find_e(self.scene, name)
	end

	function self.add_entity(e)
		table.insert(self.scene.list, e)
		return self
	end

	function self.add_entitys(es)
		for _,e in ipairs(es) do
			table.insert(self.scene.list, e)
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

	local function dispatch(event, ...)
		for _,sys in ipairs(self.systems) do
			local handle = sys[event]
			if handle then
				handle(...)
			end
		end
	end

	self.cb = {}

	function self.cb.update(dt)
		dispatch('update', dt)
		on('update', dt)

		for watcher,_ in pairs(watchers) do
			if watcher.cond(dt) then
				watcher.callback()
				if watcher.times > 0 then
					watcher.times = watcher.times - 1
					if watcher.times == 0 then
						local new_watcher = watcher.next
						if new_watcher then
							watchers[new_watcher] = true
						end
						watchers[watcher] = nil
					end
				end
			end
		end
	end

	function self.cb.draw()
		dispatch('draw')
	end

	function self.cb.mouse(what, x, y, who)
		if who == 'left' then
			if what == 'press' then
				dispatch('mousedown', x, y)
			else
				dispatch('mouseup', x, y)
			end
		elseif who == 'right' then
			if what == 'press' then
				dispatch('rmousedown', x, y)
			else
				dispatch('rmouseup', x, y)
			end
		else
			dispatch('mousemove', x, y)
		end
	end

	function self.cb.keyboard(key, what)
		if what == 'press' then
			dispatch('keydown', key)
		else
			dispatch('keyup', key)
		end
	end

	function self.cb.message(char)
		dispatch('message', char)
	end

	function self.cb.resume()
		on('resume')
	end

	function self.cb.pause()
		on('pause')
	end

	function self.cb.exit()
		on('exit')
	end

	return setmetatable(self, {__call = function (_, ...)
		on(...)
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