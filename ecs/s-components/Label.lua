local ecs = require "ecs"
local graphics = require "ecs.graphics"


return function (e, t)
	
	local self = {
		text = assert(t.text),
		font = assert(t.font),
		size = t.size or 24,
		color = t.color or 0xffffffff,
	}

	local FONT, SCALE, CHARS

	function self.init()
		local node = assert(e.node)

		FONT = graphics.font(self.font)
		SCALE = self.size/FONT.size
		CHARS = FONT.chars(self.text)

		self.width = graphics.chars_length(CHARS, SCALE)
		self.height = self.size

		function e.draw()
			if node.active then
				graphics.set_tx_color(self.color)
				graphics.draw_text(node.x - node.anchor.x * self.width, node.y - (node.anchor.y - 0.5)*self.height,
					SCALE, CHARS, node.angle, node.camera)
			end
		end

		table.insert(ecs.current_world.g.render_list, e)

		-- hook label
		local set = {}

		function set.font(name)
			self.font = name
			FONT = graphics.font(self.font)
			CHARS = FONT.chars(self.text)
			self.width = graphics.chars_length(CHARS, SCALE)
		end

		function set.size(sz)
			SCALE = sz/FONT.size
			self.size = sz
			self.height = sz
			self.width = graphics.chars_length(CHARS, SCALE)
		end

		function set.color(c)
			self.color = c
		end

		function set.text(tx)
			self.text = tx
			CHARS = FONT.chars(tx)
			self.width = graphics.chars_length(CHARS, SCALE)
		end

		e.label = setmetatable({}, {
				__index = self,
				__pairs = function () return pairs(self) end,
				__newindex = function (_,k,v) set[k](v) end
			})
	end
	

	return 'label', self
end