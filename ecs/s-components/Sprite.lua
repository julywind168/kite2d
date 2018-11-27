local ecs = require "ecs"
local graphics = require "ecs.graphics"
local util = require "ecs.util.node"


return function (e, t)
	t = t or {}

	local self = {
		texname = t.texname or "resource/white.png",
		texcoord = t.texcoord or {0,1, 0,0, 1,0, 1,1},
		color = t.color or 0xffffffff,
		vao = nil,
		vbo = nil,
		tex = nil,
	}

	function self.init()
		assert(e.node and not e.draw)

		self.tex = graphics.texture(self.texname)
		self.vao, self.vbo = graphics.sprite(
			e.node.aabb[1].x, e.node.aabb[1].y,
			e.node.aabb[2].x, e.node.aabb[2].y,
			e.node.aabb[3].x, e.node.aabb[3].y,
			e.node.aabb[4].x, e.node.aabb[4].y,
			table.unpack(self.texcoord))


		function e.draw()
			if e.node.active then
				graphics.set_sp_color(self.color)
				graphics.draw_sprite(self.vao, e.node.camera, self.tex)
			end
		end

		table.insert(ecs.current_world.g.render_list, e)

		-- hook nood
		local node = e.node

		local function on_node_update()
			util.node_calc_aabb(node)
			graphics.update_sprite_aabb(self.vbo,
				node.aabb[1].x, node.aabb[1].y,
				node.aabb[2].x, node.aabb[2].y,
				node.aabb[3].x, node.aabb[3].y,
				node.aabb[4].x, node.aabb[4].y)
		end

		local set = {}

		function set.x(x)
			node.x = x
			on_node_update()
		end

		function set.y(y)
			node.y = y
			on_node_update()
		end

		function set.angel(a)
			node.a = a
			on_node_update()
		end

		function set.active(active)
			node.active = active
		end


		e.node = setmetatable({}, {
				__index = node,
				__pairs = function () return pairs(node) end,
				__newindex = function (_,k,v) set[k](v) end
			})

		-- hook sprite
		local sp_set = {}

		function sp_set.texname(name)
			self.texname = name
			self.tex = assert(graphics.texture(name), 'failed to load texture '..tostring(name))
		end

		function sp_set.texcoord(coord)
			self.texcoord = coord
			graphics.update_sprite_texcoord(self.vbo, table.unpack(coord))			
		end

		e.sprite = setmetatable({}, {
				__index = self,
				__pairs = function () return pairs(self) end,
				__newindex = function (_,k,v) sp_set[k](v) end
			})
	end

	return 'sprite', self
end