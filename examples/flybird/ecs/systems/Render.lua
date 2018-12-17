--------------------------------------------------------------------------------------------
--
-- render 系统, 应该被最后一个(除了 Debug system)添加到 world, 因为 render.update 需要修改 UI 的状态 
--
--------------------------------------------------------------------------------------------

local gfx = require "kite.graphics"

local function Render(world)

	local self = {name='render'}
	--
	-- util
	--
	local function filter_map(e) return e.has['TAG_MAP_LAYER'] and e.active end
	local function filter_sprite(e) return e.has['TAG_SPRITE_LAYER'] and e.active end
	local function filter_ui(e) return e.has['TAG_UI_LAYER'] and e.active end
	local function filter_textfield(e) return e.has['textfield'] and e.active end


	local function get_layers()
		local maps, sprites, ui = world.get_entities(filter_map, filter_sprite, filter_ui)
		table.sort( sprites, function (a,b)
			return a.y > b.y
		end )
		return maps, sprites, ui
	end

	--
	-- update
	--
	function self.update(dt)
		local textfields = world.get_entities(filter_textfield)
		for _,e in ipairs(textfields) do
			local lab = e.label  
			local csr = e.cursor
			local w = gfx.print(lab.text, lab.fontsize, lab.x, lab.y, lab.color, lab.ax, lab.ay, 0, lab.fontname, true)
			if w < e.w-8 then
				lab.ax = 0
				lab.x = e.x - (e.w-8) * e.ax
			else
				lab.ax = 1
				lab.x = e.x + (e.w-8) * e.ax
			end
			csr.x = lab.x + (1-lab.ax) * w + 2
			if e.selected then
				e.selected = e.selected + dt
				if e.selected >= 0.5 then
					e.selected = 0
					csr.active = not csr.active
				end
			end
		end
	end

	--
	-- draw
	--
	local draw = {}

	function draw.sprite(e, cx, cy)
		local x = e.x - cx
		local y = e.y - cy
		gfx.draw(e.texname, x, y, e.ax, e.ay, e.sx, e.sy, e.rotate, e.color, e.w, e.h, e.texcoord)
	end

	draw.button = draw.sprite

	function draw.label(e, cx, cy)
		local x = e.x - cx
		local y = e.y - cy
		gfx.print(e.text, e.fontsize, x, y, e.color, e.ax, e.ay, e.rotate, e.fontname)
	end

	function draw.flipbook(e, cx, cy)
		local frame = e.frames[e.current]
		local texname = frame.texname
		local texcoord = frame.texcoord
		local x = e.x + frame.ox - cx
		local y = e.y + frame.oy - cy
		local w = frame.w
		local h = frame.h
		gfx.draw(texname, x, y, e.ax, e.ay, e.sx, e.sy, e.rotate, e.color, w, h, texcoord)
	end

	function draw.textfield(e, cx, cy)
		local bg = e.background
		local mask = e.mask
		local label = e.label
		local cursor = e.cursor
		local x = e.x - cx
		local y = e.y - cy
		gfx.draw(bg.texname, x, y, e.ax, e.ay, e.sx, e.sy, e.rotate, bg.color, e.w, e.h, bg.texcoord)
		gfx.start_stencil()
		gfx.draw(mask.texname, x, y, e.ax, e.ay, e.sx, e.sy, e.rotate, mask.color, e.w-8, e.h, mask.texcoord)
		gfx.stop_stencil()
		gfx.print(label.text, label.fontsize, label.x - cx, label.y - cy, label.color, label.ax, label.ay, 0, label.fontname)
		gfx.clear_stencil()
		if cursor.active then
			gfx.draw(cursor.texname, cursor.x - cx, cursor.y - cy, 0, 0.5, e.sx, e.sy, 0, cursor.color, 1, e.h-4, cursor.texcoord)
		end
	end

	-- 扩展
	function draw.bird(e, cx, cy)
		draw.flipbook(e, cx, cy)
		local nk = e.nick
		gfx.print(nk.text, nk.fontsize, e.x+nk.ox-cx, e.y+nk.oy-cy, nk.color, nk.ax, nk.ay, 0, nk.fontname)
	end

	local function draw_entities(entities, cx, cy)
		for _,e in ipairs(entities) do
			local draw = assert(draw[e.type], 'invalid node type '..tostring(e.type))
			draw(e, cx, cy)
		end
	end

	local camera = world.find_entity('camera')

	function self.draw()
		local maps, sprites, ui = get_layers()

		draw_entities(maps, camera.x, camera.y)
		draw_entities(sprites, camera.x, camera.y)
		draw_entities(ui, 0, 0)
	end

	return self
end

return function ()
	return function (world)
		return Render(world)
	end
end