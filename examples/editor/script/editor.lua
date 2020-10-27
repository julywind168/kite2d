local util = require "kite.util"
local inspector = require "widget.inspector"


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


return function(self)


local keyboard
local selected
local inspr_name, inspr_x, inspr_y, inspr_w, inspr_h, inspr_xs, inspr_ys

function self.ready()
	keyboard = self.keyboard()
	local _, targets = self.add_child(target)
	local inspector = self.add_child(inspector)
	inspr_name = inspector.find("name")
	inspr_x = inspector.find("input_x")
	inspr_y = inspector.find("input_y")
	inspr_w = inspector.find("input_w")
	inspr_h = inspector.find("input_h")
	inspr_xs = inspector.find("input_xs")
	inspr_ys = inspector.find("input_ys")

	function inspr_x.editing(text)
		if selected then
			selected.x = safe_tonumber(text)
		end
	end

	function inspr_y.editing(text)
		if selected then
			selected.y = safe_tonumber(text)
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
			selected = node

			inspr_name.text = node.name or "unknown"
			inspr_x.text = node.x
			inspr_y.text = node.y
			inspr_w.text = node.width or 0
			inspr_h.text = node.height or 0
			inspr_xs.text = node.xscale
			inspr_ys.text = node.yscale
		end

		function node.dragging()
			inspr_x.text = node.x
			inspr_y.text = node.y
		end
	end

	inspector.touchable = true
	inspector.draggable = true
end


function self.keydown(key)
	if key == "s" and keyboard.pressed["ctrl"] then
		dump_2_file(out, target)
	end
end





end