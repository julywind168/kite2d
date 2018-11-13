local graphics = require "fantasy.graphics"
local window = require "fantasy.window"
local camera = require "fantasy.camera"
local flag = require "ecs.flag"
local spritelist = require "ecs.spritelist"

local function sprite_agent(sp)

	local texture = sp.texname and graphics.texture(sp.texname) 
	local vao, vbo = graphics.sprite(
		sp.x, sp.y,
		sp.scalex*sp.width/window.width,
		sp.scaley*sp.height/window.height,
		sp.rotate, sp.texcoord and table.unpack(sp.texcoord))

	local agent = {
		x = sp.x,
		y = sp.y,
		z = sp.z,
		color = sp.color,
		scalex = sp.scalex,
		scaley = sp.scaley,
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
	local agents = spritelist()

	-- 事件处理
	local handler = {}

	function handler.update()
		
		local sp = agents.self
		while true do
			sp = sp.next
			if not sp then break end

			if sp.x ~= sp.self.x then
				sp.x = sp.self.x
				graphics.sprite_x(sp.vbo, sp.x)
			end
			if sp.y ~= sp.self.y then
				sp.y = sp.self.y
				graphics.sprite_y(sp.vbo, sp.y)
			end
			if sp.z ~= sp.self.z then
				agents.update_z(sp, sp.self.z)
			end

			if sp.scalex ~= sp.self.scalex then
				sp.scalex = sp.self.scalex
				graphics.sprite_scalex(sp.vbo, sp.scalex*sp.self.width/window.width)
			end
			if sp.scaley ~= sp.self.scaley then
				sp.scaley = sp.self.scaley
				graphics.sprite_scaley(sp.vbo, sp.scaley*sp.self.height/window.height)
			end
		end
	end

	function handler.draw()
		local sp = agents.self

		local cameraing = true
		local tmp = {}
		while true do
			sp = sp.next
			if not sp then break end

			if sp.self.active then
				if cameraing == true and sp.self.camera == false then
					-- ui start
					cameraing = false
					tmp.x = camera.x
					tmp.y = camera.y
					camera.x = window.width/2
					camera.y = window.height/2
				end
				graphics.set_color(sp.color)
				graphics.draw(sp.vao, sp.texture)
			end
		end

		-- start camera
		if cameraing == false then
			cameraing = true
			camera.x = tmp.x
			camera.y = tmp.y
		end
	end

	function handler.sprite_create(sp)
		if not sprites[sp] then
			local a = sprite_agent(sp)
			agents.add(a)
			sprites[sp] = a
		end
	end

	function handler.sprite_destroy(sp)
		-- local a = sprites[sp]
		-- for i=1,#agents do
		-- 	if agents[i] == a then
		-- 		table.remove(agents, i)
		-- 		break
		-- 	end
		-- end
		-- sprites[sp] = nil
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handler[event]
		if f then
			return f(...)
		end
	end})
end