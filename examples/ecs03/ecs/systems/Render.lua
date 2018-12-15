local gfx = require "kite.graphics"

local function Render(world)

	local self = {name='render'}

	local function get_maps()
		return world.get_entities(function (e)
			return e.has['TAG_MAP_LAYER'] and e.active
		end)
	end

	-- 主角 怪物 建筑 树木 ...
	local function get_sprites()
		local sprites = world.get_entities(function (e)
			return e.has['TAG_SPRITE_LAYER'] and e.active
		end)
		table.sort( sprites, function ( a,b )
			return a.y > b.y
		end)

		return sprites
	end

	local function get_ui()
		return world.get_entities(function (e)
			return e.has['TAG_UI_LAYER'] and e.active
		end)
	end


	local draw = {}

	function draw.sprite(e)
		gfx.draw(e.texname, e.x, e.y, e.ax, e.ay, e.sx, e.sy, e.rotate, e.color, e.w, e.h, e.fx, e.fy, e.texcoord)
	end

	function draw.label(e)
		e.w = gfx.print(e.text, e.fontsize, e.x, e.y, e.color, e.ax, e.ay, e.rotate, e.fontname)
	end

	function draw.flipbook(e)
		local frame = e.frames[e.current]
		local texname = frame.texname
		local texcoord = frame.texcoord
		local x = e.x + frame.ox
		local y = e.y + frame.oy
		local w = frame.w
		local h = frame.h
		gfx.draw(texname, x, y, e.ax, e.ay, e.sx, e.sy, e.rotate, e.color, w, h, e.fx ~= frame.fx, e.fy ~= frame.fx, texcoord)
	end

	local function draw_entities(entities)
		for _,e in ipairs(entities) do
			local draw= assert(draw[e.type], 'invalid node type '..tostring(e.type))
			draw(e)
		end
	end

	function self.draw()
		local maps = get_maps()
		local sprites = get_sprites()
		local ui = get_ui()
		draw_entities(maps)
		draw_entities(sprites)
		draw_entities(ui)
	end

	return self
end

return function ()
	return function (world)
		return Render(world)
	end
end