local graphics = require "fantasy.graphics"
local window = require "fantasy.window"
local camera = require "fantasy.camera"
local flag = require "ecs.flag"

local function sprite_agent(sp)

	local texture = graphics.texture(assert(sp.texname)) 
	local vao, vbo = graphics.sprite(
		sp.x, sp.y,
		sp.scalex*sp.width/window.width,
		sp.scaley*sp.height/window.height,
		sp.rotate, table.unpack(sp.texcoord))

	local agent = {
		x = sp.x,
		y = sp.y,
		vao = vao,
		vbo = vbo,
		texture = texture,
		self = sp
	}

	return agent
end
	
return function()

	local self = {}

	local sprites = {}
	local agents = {}

	-- 事件处理
	local handler = {}

	function handler.update()
		for _,sp in ipairs(agents) do
			if sp.x ~= sp.self.x then
				sp.x = sp.self.x
				graphics.sprite_x(sp.vbo, sp.x)
			end
			if sp.y ~= sp.self.y then
				sp.y = sp.self.y
				graphics.sprite_y(sp.vbo, sp.y)
			end
		end
	end

	function handler.draw()
		for _,sp in ipairs(agents) do
			if sp.self.active then
				graphics.draw(sp.vao, sp.texture)
			end
		end
	end

	function handler.sprite_create(sp)
		if not sprites[sp] then
			local a = sprite_agent(sp)
			agents[#agents+1] = a
			sprites[sp] = a
		end
	end

	function handler.sprite_destroy(sp)
		local a = sprites[sp]
		for i=1,#agents do
			if agents[i] == a then
				table.remove(agents, i)
				break
			end
		end
		sprites[sp] = nil
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handler[event]
		if f then
			return f(...)
		end
	end})
end