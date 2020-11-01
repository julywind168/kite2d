local util = require "kite.util"
local timer = require "kite.timer"
local inspector = require "widget.inspector"
local hierarchy = require "widget.hierarchy"


local target = require "widget.poker"
local out = "examples/editor/widget/poker.lua"

local HEAD = "--[[\n"..[[
	@Time:	  %s
	@Author:  Kite Editor v0.01
]].."]]\n"

local function dump_2_file(filename, obj)
	local f = io.open(filename, 'w')
	f:write(string.format(HEAD, os.date('%Y/%m/%d %H:%M:%S')))
	f:write('return '..util.pack(obj))
	f:close()
end


local function safe_tonumber(n)
	return tonumber(n) or 0
end

local function hiry_item(node, offset_x, content_width)
	local rect_w = content_width - 40 - 20 - offset_x-8-10
	local rect_x = (content_width-rect_w)/2-20-10
	local triangle_x = -content_width/2+20+offset_x+10
	local triangle_visible = node.nchild > 0

	return {
		type='empty', x=0, y=0, width=380, height=30,
		{name='rect', type='sprite', x=rect_x, y=0, width=rect_w, height=30, image="image/white.png", color=0x66665500},
		{name="triangle", type='sprite', x=triangle_x, y=0, width=16, height=16, image="image/right_triangle.png", angle=270, visible = triangle_visible},
		{type="label", xalign='left', x=triangle_x+18, y=0, width=100, height=30, text=node.name, font="generic", size=28, color=0xccccccff},
		{name='eye_open', type='button', x=380/2-28/2-2, y=0, width=28, height=24, image="image/eye_open.png", visible=node.node.visible},
		{name='eye_close', type='button', x=380/2-28/2-2, y=0, width=28, height=24, image="image/eye_close.png", visible=not node.node.visible},
	}
end

local function contents_y_sort(contents, content_height)
	local ITEM_H = 30
	local y = content_height/2

	for i,node in ipairs(contents) do
		if node.visible then
			y = y - ITEM_H
			node.y = y
		end
	end
end

local function show_item_children(contents, i)
	local item = contents[i]
	for i=i+1,#contents do
		local node = contents[i]
		if not node or node.node_lv <= item.node_lv then
			break
		end
		node.show()
	end
end

local function hide_item_children(contents, i)
	local item = contents[i]
	for i=i+1,#contents do
		local node = contents[i]
		if not node or node.node_lv <= item.node_lv then
			break
		end
		node.hide()
	end
end

return function(self)


local keyboard
local selected, cross
local hiry_content, inspr_name, inspr_x, inspr_y, inspr_w, inspr_h, inspr_xs, inspr_ys


local function update_cross_pos()
	cross.x, cross.y = cross.world2local_position(selected.world_position())
end

function self.ready()
	keyboard = self.keyboard()
	local _, targets = self.add_child(target)
	local inspector = self.add_child(inspector)
	local hierarchy = self.add_child(hierarchy)
	cross = self.add_child{type='sprite',x=0, y=0, width=19, height=19, image="image/cross.png"}

	inspr_name = inspector.find("name")
	inspr_x = inspector.find("input_x")
	inspr_y = inspector.find("input_y")
	inspr_w = inspector.find("input_w")
	inspr_h = inspector.find("input_h")
	inspr_xs = inspector.find("input_xs")
	inspr_ys = inspector.find("input_ys")

	local contents = {}

	local function set_selected(node)
		selected = node
		inspr_name.text = node.name or "unknown"
		inspr_x.text = node.x
		inspr_y.text = node.y
		inspr_w.text = node.width or 0
		inspr_h.text = node.height or 0
		inspr_xs.text = node.xscale
		inspr_ys.text = node.yscale

		for i,item in ipairs(contents) do
			if item.target_node == node then
				item.find("rect").color = 0x555555ff
			else
				item.find("rect").color = 0x55555500
			end
		end
	end

	-- hierarchy
	hiry_content = hierarchy.find("content")

	local target_lv = targets[1].lv
	for i,node in ipairs(targets) do
		local offset_x = (node.lv - target_lv) * 20
		local item = hiry_content.add_child(hiry_item(node, offset_x, hiry_content.width))
		item.node_lv = node.lv
		item.target_node = node

		-- backgroud rect
		local rect = item.find("rect")

		rect.enabletouch()

		function rect.gained_focus()
			rect.color = 0x555555ff
			set_selected(node)
		end
		
		function rect.lost_focus()
			rect.color = 0x55555500
		end
		
		-- triangle
		local triangle = item.find("triangle")

		triangle.enabletouch()

		function triangle.on_pressed()
			if triangle.angle == 0 then
				triangle.angle = 270
				show_item_children(contents, i)
			else
				triangle.angle = 0
				hide_item_children(contents, i)
			end
			contents_y_sort(contents, hiry_content.height)
		end

		-- eye
		local eye_open = item.find("eye_open")
		local eye_close = item.find("eye_close")

		function eye_open.on_pressed()
			eye_open.hide()
			eye_close.show()
			node.hide()
		end

		function eye_close.on_pressed()
			eye_close.hide()
			eye_open.show()
			node.show()
		end


		contents[i] = item
	end

	contents_y_sort(contents, hiry_content.height)

	-- inspector

	function inspr_x.editing(text)
		if selected then
			selected.x = safe_tonumber(text)
			update_cross_pos()
		end
	end

	function inspr_y.editing(text)
		if selected then
			selected.y = safe_tonumber(text)
			update_cross_pos()
		end
	end

	function inspr_w.editing(text)
		if selected then
			selected.width = safe_tonumber(text)
		end
	end

	function inspr_h.editing(text)
		if selected then
			selected.height = safe_tonumber(text)
		end
	end

	function inspr_xs.editing(text)
		if selected then
			selected.xscale = safe_tonumber(text)
		end
	end

	function inspr_ys.editing(text)
		if selected then
			selected.yscale = safe_tonumber(text)
		end
	end


	for _,node in ipairs(targets) do
		if node.type ~= "empty" then
			node.touchable = true
			node.draggable = true
		end

		local old_gained_focus = node.gained_focus

		function node.gained_focus()
			if old_gained_focus then
				old_gained_focus()
			end

			set_selected(node)
		end

		function node.dragging()
			inspr_x.text = node.x
			inspr_y.text = node.y
		end
	end

	inspector.touchable = true
	inspector.draggable = true
	hierarchy.touchable = true
	hierarchy.draggable = true
end


function self.update()
	if selected then
		if keyboard.lpressed['up'] then
			selected.y = selected.y + 5
			inspr_y.text = selected.y
		elseif keyboard.lpressed['down'] then
			selected.y = selected.y - 5
			inspr_y.text = selected.y
		elseif keyboard.lpressed['left'] then
			selected.x = selected.x - 5
			inspr_x.text = selected.x
		elseif keyboard.lpressed['right'] then
			selected.x = selected.x + 5
			inspr_x.text = selected.x
		end
	end
end


function self.keyup(key)
	if selected then
		local step = keyboard.pressed['shift'] and 5 or 1
		if key == 'up' then
			selected.y = selected.y + step
			inspr_y.text = selected.y
			return true
		elseif key == 'down' then
			selected.y = selected.y - step
			inspr_y.text = selected.y
			return true
		elseif key == 'left' then
			selected.x = selected.x - step
			inspr_x.text = selected.x
			return true
		elseif key == 'right' then
			selected.x = selected.x + step
			inspr_x.text = selected.x
			return true
		end
	end
end


function self.keydown(key)
	if key == "s" and keyboard.pressed["ctrl"] then
		dump_2_file(out, target)
	end
end


end