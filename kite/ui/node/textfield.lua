local gfx = require "kite.graphics"
local timer = require "kite.timer"
local transform_attr = {x=true, y=true, width=true, height=true, xscale=true, yscale=true, angle=true}


local CURSOR_WIDTH = 1		-- 光标宽 1px
local CURSOR_SPACEX = 3		-- 光标横向占据的空间 3px
--
-- 文本输入框 由背景图片,光标图片,文本以及遮罩组成
--
return function (node, mt, proxy)
	local cursor_visible = false
	
	mt.world_width = node.width * mt.world_xscale
	mt.world_height = node.height * mt.world_yscale

	local bg = gfx.sprite {
		x = mt.world_x,
		y = mt.world_y,
		width = mt.world_width,
		height = mt.world_height,
		angle = mt.world_angle,
		image = node.bg_image,
		color = node.bg_color or 0x222222ff,
	}

	local label = gfx.label {
		x = mt.world_x - mt.world_width/2 + CURSOR_SPACEX,
		y = mt.world_y,
		angle = mt.world_angle,
		xscale = mt.world_xscale,
		yscale = mt.world_yscale,

		text = node.text,
		font = node.font,
		color = node.color or 0xddddddff,
		size = node.size,
		xalign = "left",
		yalign = "center"
	}

	if label.text_width > mt.world_width then
		label.x = mt.world_x + mt.world_width/2 - CURSOR_SPACEX
		label.xalign = "right"
		label.update_transform()
	end

	local function label_x()
		if label.xalign == "left" then
			return mt.world_x - mt.world_width/2
		else
			assert(label.xalign == "right")
			return mt.world_x + mt.world_width/2 - CURSOR_SPACEX
		end
	end

	local function cursor_x()
		if label.xalign == "left" then
			return label.x + label.text_width + CURSOR_SPACEX/2
		elseif label.xalign == "center" then
			return label.x + label.text_width/2 + CURSOR_SPACEX/2
		else
			return label.x + CURSOR_SPACEX/2
		end
	end

	local cursor = gfx.sprite {
		x = cursor_x(),
		y = mt.world_y,
		width = CURSOR_WIDTH,
		height = label.text_height,
		angle = mt.world_angle,
		image = node.cursor_image,
		color = node.color or 0xddddddff,	
	}

	-- mt func (use by framwork)
	function mt.update_text(text)
		node.text = text
		label.set_text(text)

		if label.text_width > mt.world_width and label.xalign == "left" then
			label.xalign = "right"
			label.x = mt.world_x + mt.world_width/2 - 3
			label.update_transform()
		elseif label.text_width <= mt.world_width and label.xalign == "right" then
			label.xalign = "left"
			label.x = mt.world_x - mt.world_width/2 + 3
			label.update_transform()
		end
		cursor.x = cursor_x()
		cursor.update_transform()
	end

	function mt.draw()
		bg.draw()

		-- use 'bg' for mask
		gfx.start_stencil()
		bg.draw()	
		gfx.stop_stencil()
		label.draw()
		gfx.clear_stencil()
		
		if mt.editing and cursor_visible then
			cursor.draw()
		end
	end

	function mt.update_transform()
		mt.world_width = node.width * mt.world_xscale
		mt.world_height = node.height * mt.world_yscale

		bg.x = mt.world_x
		bg.y = mt.world_y
		bg.width = mt.world_width
		bg.height = mt.world_height
		bg.angle = mt.world_angle
		bg.update_transform()

		label.x = label_x()
		label.y = mt.world_y
		label.xscale = mt.world_xscale
		label.yscale = mt.world_yscale
		label.angle = mt.world_angle
		label.update_transform()

		cursor.x = cursor_x()
		cursor.y = mt.world_y
		cursor.width = CURSOR_WIDTH
		cursor.height = label.text_height
		cursor.angle = mt.world_angle
		cursor.update_transform()
	end

	-- textfield attr
	mt.touchable = true

	-- blink timer
	local tm = timer.create(0.5, function ()
		cursor_visible = not cursor_visible
	end, -1)

	function proxy.gained_focus()
		mt.editing = true
		cursor_visible = true
		tm.resume()
	end

	function proxy.lost_focus()
		mt.editing = false
		tm.pause()
	end


	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if k == "color" then
			assert(type(v) == "number" and v >= 0)
			node.color = v
			sprite.set_color(v)
		elseif node[k] then
			if transform_attr[k] then
				mt.modify[k] = v
			else
				error(k.." is read-only")
			end
		else
			rawset(proxy, k, v)
		end
	end})
end