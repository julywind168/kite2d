local kite = require "kite"
local rotate = require "kite.util".rotate
local system_input = require "kite.ui.system.input"
local transition = require "kite.ui.transition"
local animation = require "kite.ui.animation"

local create = {
	empty = require "kite.ui.node.empty",
	sprite = require "kite.ui.node.sprite",
	label = require "kite.ui.node.label",
	button = require "kite.ui.node.button",
	textfield = require "kite.ui.node.textfield"
}


-- 你可以编写自己的缩放方案,这里使用最简单的 【填充整个屏幕】 方案
local WORLD = {world_x=0, world_y=0, world_angle=0, world_xscale=1, world_yscale=1, lv=-1, visible = true}
WORLD.world_xscale = kite.window_width()/application.design_width
WORLD.world_yscale = kite.window_height()/application.design_height


local function create_list(root)

	local list = {root = root}

	function list.init(items)
		local n = #items
		assert(n > 0)
		list.head = items[1]
		list.tail = items[n]

		if n > 1 then
			list.head.next = items[2]
			list.tail.previous = items[n-1]

			if n > 2 then
				for i=2,n-1 do
					local item = items[i]
					item.previous = items[i-1]
					item.next = items[i+1]
				end
			end
		end
	end

	local function find_tail(item)
		if item.nchild == 0 then
			return item
		else
			local cur = item.next
			while cur do
				if cur.lv <= item.lv then
					return cur.previous
				end
				if cur.next == nil then
					return cur
				else
					cur = cur.next
				end
			end
		end
	end
	
	list.find_tail = find_tail

	-- 向后遍历找 第n个子节点
	local function find_child(parent, n)
		local c = 0
		local cur = parent.next

		while cur do
			if cur.lv == parent.lv + 1 then
				c = c + 1
				if c == n then
					return cur
				end
			end
			cur = cur.next
		end
	end
	

	function list.insert(parent, i, items)
		local point
		if i == 1 then
			point = parent
		else
			local child = assert(find_child(parent, i-1))
			point = find_tail(child)
		end

		local point_next = point.next
		local n = #items
		local first = items[1]
		local last = items[n]
		first.previous = point
		point.next = first
		last.next = point_next
		if not point_next then
			list.tail = last
		else
			point_next.previous = last
		end

		if n > 1 then
			first.next = items[2]
			last.previous = items[n-1]

			if n > 2 then
				for i=2,n-1 do
					local item = items[i]
					item.previous = items[i-1]
					item.next = items[i+1]
				end	
			end
		end

		parent.nchild = parent.nchild + 1
	end

	function list.remove(item)
		local parent = item.parent
		local tail = find_tail(item)
		local next_one = tail.next
		local previous_one = assert(item.previous)
		
		previous_one.next = next_one

		if next_one then
			next_one.previous = previous_one
		else
			list.tail = previous_one
		end

		parent.nchild = parent.nchild - 1
	end

	function list.item_show(item)
		local parent = item.parent
		if not parent.visible then
			return
		end

		local tail = find_tail(item)
		local cur = item
		while cur do
			cur.visible = cur.node.visible
			if cur == tail then
				break
			else
				cur = cur.next
			end
		end
	end

	function list.item_hide(item)
		local tail = find_tail(item)
		local cur = item
		while cur do
			cur.visible = false
			if cur == tail then
				break
			else
				cur = cur.next
			end
		end
	end


	function list.foreach(f)
		local cur = list.head

		while cur do
			if cur.visible and f(cur) then
				break
			else
				cur = cur.next
			end
		end
	end

	function list.foreach_from_tail(f)
		local cur = list.tail

		while cur do
			if cur.visible and f(cur) then
				break
			else
				cur = cur.previous
			end
		end
	end

	-- find node in children with name
	function list.find(node, name)
		if node.name == name then
			return node
		end

		local cur = node.next
		while cur do
			if cur and cur.lv > node.lv then
				if cur.name == name then
					return cur
				else
					cur = cur.next
				end
			else
				return
			end
		end
	end

	return list
end



local M = {}


local function node_init(node, parent_proxy, list, tree)
	
	local index = 0
	local proxys = {}

	local function init(node, parent_proxy)
		node.name = node.name or "unknow"
		node.visible = (node.visible == nil and true) or node.visible or false
		node.xscale = node.xscale or 1
		node.yscale = node.yscale or 1
		node.angle = node.angle or 0
		
		local proxy = {
			node = node,
			name = node.name,
			visible = node.visible and parent_proxy.visible or false,	-- 必须父节点和自己都是可见的才是可见的
			type = node.type,
			lv = parent_proxy.lv + 1,
			nchild = #node,
			node = node,
			proxy = proxy,
			parent = parent_proxy,

			_x = node.x,	-- 与世界坐标同步更新, 用来计算世界坐标与本地坐标的差值
			_y = node.y,
			world_x = node.x * parent_proxy.world_xscale + parent_proxy.world_x,
			world_y = node.y * parent_proxy.world_yscale + parent_proxy.world_y,
			world_angle = node.angle + parent_proxy.world_angle,
			world_xscale = node.xscale * parent_proxy.world_xscale,
			world_yscale = node.yscale * parent_proxy.world_yscale,
			modify = {}
		}

		if parent_proxy.world_angle ~= 0 then
			proxy.world_x, proxy.world_y = rotate(parent_proxy.world_x, parent_proxy.world_y, parent_proxy.world_angle, proxy.world_x, proxy.world_y)
		end
		
		-- proxy base interface
		function proxy.list()
			return list
		end

		function proxy.tree()
			return tree
		end

		function proxy.keyboard()
			return tree.keyboard
		end

		function proxy.world2local_position(x, y)
			return x - (proxy.world_x - proxy._x), y - (proxy.world_y - proxy._y)
		end

		function proxy.world_position()
			local world_x = parent_proxy.world_x + node.x * parent_proxy.world_xscale
			local world_y = parent_proxy.world_y + node.y * parent_proxy.world_yscale
			return world_x, world_y
		end

		function proxy.show()
			if proxy.visible then
				return
			end
			node.visible = true
			list.item_show(proxy)
		end

		function proxy.hide()
			if proxy.visible == false then
				return
			end
			node.visible = false
			list.item_hide(proxy)
		end

		function proxy.find(name)
			return list.find(proxy, name)
		end

		function proxy.find_in_tree(name)
			local target
			list.foreach(function (item)
				if item.name == name then
					target = item
					return true
				end
			end)
			return target
		end

		function proxy.add_child(child, i)
			i = i or proxy.nchild + 1
			table.insert(node, i, child)

			local children = node_init(child, proxy, list)
			list.insert(proxy, i, children)

			-- dispatch 'ready' event on join tree
			for _,child in ipairs(children) do
				local ready = child["ready"]
				if ready then
					ready()
				end
			end
			return children[1], children
		end

		function proxy.remove_self()
			list.remove(proxy)
		end

		-- your extension
		function proxy.enabletouch()
			proxy.touchable = true
		end

		local f = assert(create[node.type], tostring(node.type))
		f(node, proxy)

		if node.script then
			require(node.script)(proxy)
		end

		index = index + 1
		proxys[index] = proxy

		for i,child in ipairs(node) do
			init(child, proxy, list)
		end
	end

	init(node, parent_proxy)

	return proxys
end


function M.tree(root)

	local self = {
		keyboard = {
			pressed = {},
			lpressed = {}	-- long pressed key
		}
	}

	local list = create_list(root)
	list.init(node_init(root, WORLD, list, self))

	local function draw_node(proxy)
		local parent_proxy = proxy.parent
		local node = proxy.node

		if proxy.modified or parent_proxy.modified then
			proxy._x = node.x
			proxy._y = node.y
			proxy.world_x = parent_proxy.world_x + node.x * parent_proxy.world_xscale
			proxy.world_y = parent_proxy.world_y + node.y * parent_proxy.world_yscale
			proxy.world_xscale = node.xscale * parent_proxy.world_xscale
			proxy.world_yscale = node.yscale * parent_proxy.world_yscale
			proxy.world_angle = node.angle + parent_proxy.world_angle

			if parent_proxy.world_angle ~= 0 then
				proxy.world_x, proxy.world_y = rotate(parent_proxy.world_x, parent_proxy.world_y, parent_proxy.world_angle, proxy.world_x, proxy.world_y)
			end

			if proxy.update_transform then
				proxy.update_transform()
			end
			proxy.modified = true
		end

		if proxy.draw then
			proxy.draw()
		end
	end

	local systems = {}


	function self.draw()
		list.foreach(draw_node)
	end

	function self.add_system(system)
		table.insert(systems, system(list, self))
	end

	function self.dispatch(event, ...)
		if event == "update" then
			transition.update(...)
			animation.update(...)
		end

		for _,sys in ipairs(systems) do
			if sys(event, ...) then
				return
			end
		end
		local cur = list.head
		while cur do
			local f = cur[event]
			if f and f(...)then
				break
			end
			cur = cur.next
		end
	end

	-- add ui system
	self.add_system(system_input)


	self.dispatch("ready")

	return self
end


return M