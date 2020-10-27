local gfx = require "kite.graphics"
local timer = require "kite.timer"
local transform_attr = {x=true, y=true, width=true, height=true, xscale=true, yscale=true, angle=true}

local function try(o, method, ...)
	local f = o[method]
	if f then
		return f(...)
	end
end

local CURSOR_WIDTH = 1		-- 光标宽 1px
local CURSOR_SPACEX = 3		-- 光标横向占据的空间 3px
--
-- 文本输入框 由背景图片,光标图片,文本以及遮罩组成
--
return function (node, proxy)
	local cursor_visible = false
	
	proxy.world_width = node.width * proxy.world_xscale
	proxy.world_height = node.height * proxy.world_yscale

	local bg = gfx.sprite {
		x = proxy.world_x,
		y = proxy.world_y,
		width = proxy.world_width,
		height = proxy.world_height,
		angle = proxy.world_angle,
		image = node.bg_image,
		color = node.bg_color or 0x222222ff,
	}

	local label = gfx.label {
		x = proxy.world_x - proxy.world_width/2,
		y = proxy.world_y,
		angle = proxy.world_angle,
		xscale = proxy.world_xscale,
		yscale = proxy.world_yscale,

		text = node.text,
		font = node.font,
		color = node.color or 0xddddddff,
		size = node.size,
		xalign = "left",
		yalign = "center"
	}

	if label.text_width > proxy.world_width then
		label.x = proxy.world_x + proxy.world_width/2 - CURSOR_SPACEX
		label.xalign = "right"
		label.update_transform()
	end

	local function label_x()
		if label.xalign == "left" then
			return proxy.world_x - proxy.world_width/2
		else
			assert(label.xalign == "right")
			return proxy.world_x + proxy.world_width/2 - CURSOR_SPACEX
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
		y = proxy.world_y,
		width = CURSOR_WIDTH,
		height = label.text_height,
		angle = proxy.world_angle,
		image = node.cursor_image,
		color = node.color or 0xddddddff,	
	}

	function proxy.update_text(text)
		local old_text = node.text
		node.text = text
		label.set_text(text)

		if label.text_width > proxy.world_width and label.xalign == "left" then
			label.xalign = "right"
			label.x = label_x()
			label.update_transform()
		elseif label.text_width <= proxy.world_width and label.xalign == "right" then
			label.xalign = "left"
			label.x = label_x()
			label.update_transform()
		end
		cursor.x = cursor_x()
		cursor.update_transform()
		try(proxy, "editing", text, old_text)
	end

	function proxy.draw()
		bg.draw()

		-- use 'bg' for mask
		gfx.start_stencil()
		bg.draw()	
		gfx.stop_stencil()
		label.draw()
		gfx.clear_stencil()
		
		if proxy.selected and cursor_visible then
			cursor.draw()
		end
	end

	function proxy.update_transform()
		proxy.world_width = node.width * proxy.world_xscale
		proxy.world_height = node.height * proxy.world_yscale

		bg.x = proxy.world_x
		bg.y = proxy.world_y
		bg.width = proxy.world_width
		bg.height = proxy.world_height
		bg.angle = proxy.world_angle
		bg.update_transform()

		label.x = label_x()
		label.y = proxy.world_y
		label.xscale = proxy.world_xscale
		label.yscale = proxy.world_yscale
		label.angle = proxy.world_angle
		label.update_transform()

		cursor.x = cursor_x()
		cursor.y = proxy.world_y
		cursor.width = CURSOR_WIDTH
		cursor.height = label.text_height
		cursor.angle = proxy.world_angle
		cursor.update_transform()
	end

	-- textfield attr
	proxy.touchable = true

	-- blink timer
	local tm = timer.create(0.5, function ()
		cursor_visible = not cursor_visible
	end, -1)

	function proxy.gained_focus()
		proxy.selected = true
		cursor_visible = true
		tm.resume()
	end

	function proxy.lost_focus()
		proxy.selected = false
		tm.pause()
	end


	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if k == "color" then
			assert(type(v) == "number" and v >= 0)
			node.color = v
			sprite.set_color(v)
		elseif k == "text" then
			proxy.update_text(tostring(v))
		elseif node[k] then
			if transform_attr[k] then
				node[k] = v
				proxy.modified = true
			else
				error(k.." is read-only")
			end
		else
			rawset(proxy, k, v)
		end
	end})
end