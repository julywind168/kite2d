--------------------------------------------------------------------------------------------
--
-- render 系统, 应该被最后一个(除了 Debug system)添加到 world, 因为 render.update 需要修改 UI 的状态 
--
--------------------------------------------------------------------------------------------
local gfx = require "kite.graphics"
local eye_foreach = eye_foreach

local function Render(world)
	
	local self = {}

	function self.update(dt)
		eye_foreach(function (root, e)
			if e.type ~= 'textfield' then return end

			local x =  root.x + e.x
			local y =  root.y + e.y
			local sx =  root.sx * e.sx
			local sy =  root.sy * e.sy
			local ew = e.w * sx
			local eh = e.h * sy

			local lab = e.label  
			local csr = e.cursor
			local w = gfx.print(lab.text, lab.fontsize * sx, x + lab.x, y + lab.y, lab.color, lab.ax, lab.ay, 0, lab.fontname, true)
			if w < ew-8 then
				lab.ax = 0
				lab.x = - (ew-8) * e.ax
			else
				lab.ax = 1
				lab.x = (ew-8) * e.ax
			end
			csr.x = lab.x + (1-lab.ax) * w + 2
			if e.selected then
				e.selected = e.selected + dt
				if e.selected >= 0.5 then
					e.selected = 0
					csr.active = not csr.active
				end
			end	
		end, world.scene)
	end

	local draw = {}

	function draw.avatar(x, y, sx, sy, rotate, e)
		local flipbook = e.actions[e.cur_action]
		local frame = flipbook.frames[flipbook.current]
		if #frame > 0 then
			for _,fm in ipairs(frame) do
				local x = x + fm.x
				local y = y + fm.y
				local w = fm.w * fm.sx * sx
				local h = fm.h * fm.sy * sy
				local rotate = fm.rotate + rotate
				gfx.draw(fm.texname, x, y, e.ax, e.ay, rotate, e.color, w, h, fm.texcoord)
			end
		else
			local x = x + frame.x
			local y = y + frame.y
			local w = frame.w * frame.sx * sx
			local h = frame.h * frame.sy * sy
			local rotate = frame.rotate + rotate
			gfx.draw(frame.texname, x, y, e.ax, e.ay, rotate, e.color, w, h, frame.texcoord)
		end
	end

	function draw.flipbook(x, y, sx, sy, rotate, e)

		local frame = e.frames[e.current]
		if #frame > 0 then
			for _,fm in ipairs(frame) do
				local x = x + fm.x
				local y = y + fm.y
				local w = fm.w * fm.sx * sx
				local h = fm.h * fm.sy * sy
				local rotate = fm.rotate + rotate
				gfx.draw(fm.texname, x, y, e.ax, e.ay, rotate, e.color, w, h, fm.texcoord)
			end
		else
			local x = x + frame.x
			local y = y + frame.y
			local w = frame.w * frame.sx * sx
			local h = frame.h * frame.sy * sy
			local rotate = frame.rotate + rotate
			gfx.draw(frame.texname, x, y, e.ax, e.ay, rotate, e.color, w, h, frame.texcoord)
		end
	end

	function draw.textfield(x, y, sx, sy, rotate, e)
		local bg = e.background
		local mask = e.mask
		local label = e.label
		local cursor = e.cursor
		local w = e.w * sx
		local h = e.h * sy
		gfx.draw(bg.texname, x, y, e.ax, e.ay, rotate, bg.color, w, h, bg.texcoord)
		gfx.start_stencil()
		gfx.draw(mask.texname, x, y, e.ax, e.ay, e.rotate, mask.color, w-8, h, mask.texcoord)
		gfx.stop_stencil()
		gfx.print(label.text, label.fontsize * sx, x+label.x, y+label.y, label.color, label.ax, label.ay, 0, label.fontname)
		gfx.clear_stencil()
		if cursor.active then
			gfx.draw(cursor.texname, x+cursor.x, y+cursor.y, 0, 0.5, 0, cursor.color, 1, h-4, cursor.texcoord)
		end
	end

	function draw.mask(x, y, sx, sy, rotate, e)
		gfx.start_stencil()
		gfx.draw(e.texname, x, y, e.ax, e.ay, rotate, e.color, e.w*sx, e.h*sy, e.texcoord)
		gfx.stop_stencil()
	end

	function draw.label(x, y, sx, sy, rotate, e)		
		if e.bordersize > 0 then
			gfx.print(e.text, e.fontsize * sx, x-e.bordersize, y, e.bordercolor, e.ax, e.ay, rotate, e.fontname)
			gfx.print(e.text, e.fontsize * sx, x+e.bordersize, y, e.bordercolor, e.ax, e.ay, rotate, e.fontname)
			gfx.print(e.text, e.fontsize * sx, x, y-e.bordersize, e.bordercolor, e.ax, e.ay, rotate, e.fontname)
			gfx.print(e.text, e.fontsize * sx, x, y+e.bordersize, e.bordercolor, e.ax, e.ay, rotate, e.fontname)
		end
		e.w = gfx.print(e.text, e.fontsize * sx, x, y, e.color, e.ax, e.ay, rotate, e.fontname)
	end

	function draw.sprite(x, y, sx, sy, rotate, e)
		gfx.draw(e.texname, x, y, e.ax, e.ay, rotate, e.color, e.w*sx, e.h*sy, e.texcoord)
	end

	draw.button = draw.sprite

	local function draw_entity(root, e)

		if not e.has['node'] or not e.active then return end

		if e.type ~= 'nil' then
			local f = assert(draw[e.type], e.type)
			local x =  root.x + e.x
			local y =  root.y + e.y
			local sx =  root.sx * e.sx
			local sy =  root.sy * e.sy
			local rotate =  root.rotate + e.rotate
			f(x, y, sx, sy, rotate, e)
		end

		if e.has['group'] and #e.list > 0 then
			local root = {
				x = root.x + e.x,
				y = root.y + e.y,
				sx = root.sx * e.sx,
				sy = root.sy * e.sy,
				rotate = root.rotate + e.rotate,
			}

			for _,_e in ipairs(e.list) do
				draw_entity(root, _e)
			end
		end

		if e.type == 'mask' then
			gfx.clear_stencil()
		end
	end

	local root = {x = 0, y = 0, sx = 1, sy = 1, rotate = 0}
	function self.draw()
		draw_entity(root, world.scene)
	end

	return self
end

return function ()
	return function (world)
		return Render(world)
	end
end