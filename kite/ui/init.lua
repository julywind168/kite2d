local kite = require "kite"
local rotate = require "kite.util".rotate
local system_touch = require "kite.ui.system.touch"

local create = {
	empty = require "kite.ui.node.empty",
	sprite = require "kite.ui.node.sprite",
	label = require "kite.ui.node.label",
	button = require "kite.ui.node.button",
}


-- 你可以编写自己的缩放方案,这里使用最简单的 【填充整个屏幕】 方案
local WORLD = {world_x=0, world_y=0, world_angle=0, world_xscale=1, world_yscale=1, lv=-1}
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
				cur = cur.next
			end
			return list.tail
		end
	end

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
		point.next = first
		last.next = point_next

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

	function list.foreach(f)
		local cur = list.head

		while cur do
			if f(cur) then
				break
			else
				cur = cur.next
			end
		end
	end

	function list.foreach_from_tail(f)
		local cur = list.tail

		while cur do
			if f(cur) then
				break
			else
				cur = cur.previous
			end
		end
	end

	-- find node in children with name
	function list.find(node, name)
		local cur = node.next
		while cur do
			if cur and cur.lv > node.lv then
				if cur.name == name then
					return cur.proxy
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


local function node_init(node, parent_mt, list)
	
	local index = 0
	local mt_array = {}

	local function init(node, parent_mt)
		node.xscale = node.xscale or 1
		node.yscale = node.yscale or 1
		node.angle = node.angle or 0
		
		local proxy = {}

		local mt = {
			name = node.name,
			lv = parent_mt.lv + 1,
			nchild = #node,
			node = node,
			proxy = proxy,
			parent = parent_mt,

			world_x = node.x * parent_mt.world_xscale + parent_mt.world_x,
			world_y = node.y * parent_mt.world_yscale + parent_mt.world_y,
			world_angle = node.angle + parent_mt.world_angle,
			world_xscale = node.xscale * parent_mt.world_xscale,
			world_yscale = node.yscale * parent_mt.world_yscale,
			modify = {}
		}
		if parent_mt.world_angle ~= 0 then
			mt.world_x, mt.world_y = rotate(parent_mt.world_x, parent_mt.world_y, parent_mt.world_angle, mt.world_x, mt.world_y)
		end
		
		function proxy.tree()
			return list.root
		end

		function proxy.find_in_tree(name)
			local target
			list.foreach(function (item)
				if item.name == name then
					target = item.proxy
					return true
				end
			end)
			return target
		end
		
		function proxy.find(name)
			return list.find(mt, name)
		end

		function proxy.remove_self()
			list.remove(mt)
		end

		function proxy.add_child(child, i)
			i = i or mt.nchild + 1
			table.insert(node, i, child)

			local children = node_init(child, mt, list)
			list.insert(mt, i, children)

			-- dispatch 'ready' event on join tree
			for _,child in ipairs(children) do
				local ready = child.proxy["ready"]
				if ready then
					ready()
				end
			end
		end

		function proxy.enabletouch()
			mt.touchable = true
		end

		local f = assert(create[node.type], tostring(node.type))
		f(node, mt, proxy)

		if node.script then
			require(node.script)(proxy, mt)
		end

		index = index + 1
		mt_array[index] = mt

		for i,child in ipairs(node) do
			init(child, mt, list)
		end
	end

	init(node, parent_mt)

	return mt_array
end


function M.tree(root)
	local list = create_list(root)
	list.init(node_init(root, WORLD, list))

	local self = {}

	local function draw_node(mt)
		local parent_mt = mt.parent
		local node = mt.node
		mt.modified = false
		if next(mt.modify) then
			mt.modified = true
			for k,v in pairs(mt.modify) do
				node[k] = v
			end
			mt.modify = {}
		end

		if mt.modified or parent_mt.modified then
			mt.world_x = parent_mt.world_x + node.x * parent_mt.world_xscale
			mt.world_y = parent_mt.world_y + node.y * parent_mt.world_yscale
			mt.world_xscale = node.xscale * parent_mt.world_xscale
			mt.world_yscale = node.yscale * parent_mt.world_yscale
			mt.world_angle = node.angle + parent_mt.world_angle

			if parent_mt.world_angle ~= 0 then
				mt.world_x, mt.world_y = rotate(parent_mt.world_x, parent_mt.world_y, parent_mt.world_angle, mt.world_x, mt.world_y)
			end

			if mt.update_transform then
				mt.update_transform()
			end
			mt.modified = true
		end

		if mt.draw then
			mt.draw()
		end
	end

	local systems = {}


	function self.draw()
		list.foreach(draw_node)
	end

	function self.add_system(system)
		table.insert(systems, system(list))
	end

	function self.dispatch(event, ...)
		for _,sys in ipairs(systems) do
			if sys(event, ...) then
				return
			end
		end
		local cur = list.head
		while cur do
			local f = cur.proxy[event]
			if f and f(...)then
				break
			end
			cur = cur.next
		end
	end

	-- add ui system
	self.add_system(system_touch)


	self.dispatch("ready")

	return self
end


return M