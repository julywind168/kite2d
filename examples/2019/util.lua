local ecs = require 'ecs'
local Render = require 'ecs.systems.Render'
local Input = require 'ecs.systems.Input'
local Moving = require 'ecs.systems.Moving'
local Gravity = require 'ecs.systems.Gravity'
local Animation = require 'ecs.systems.Animation'
local Debug = require 'ecs.systems.Debug'

local create = require 'ecs.functions'


local M = {switch = {}}


function M.switch.fade(time, callback)

	local speed = 0xff * 2 / time
	local color = 0
	local mask = create.sprite{ x = 480, y = 320, w = 960, h = 640, color = 0 } 

	return function (world, old, new, new_handle)

		world.handle = nil
		old.list[#old.list+1] = mask

		world.watch(function (dt)
			if math.ceil(color) >= 0xff then
				return true
			end
			color = color + speed * dt
			mask.color = math.floor(color)
		end,function ()
			color = 0xff
			mask.color = color
			old.list[#old.list] = nil
			new.list[#new.list+1] = mask
			world.set_scene(new)
		end)
		.join(function (dt)
			color = color - speed * dt
			mask.color = math.floor(color)
			return color <= 0
		end, function ()
			new.list[#new.list] = nil
			world.set_handle(new_handle)
			if callback then callback() end
		end)
	end
end

function M.switch.slide(direct, time, callback)
	local dist = (direct == 'left' or direct == 'right') and 960 or 640
	local time = time or 2
	local speed = dist/time

	return function (world, old, new, new_handle)

		world.handle = nil
		local root, direction, cond
		local oldx = new.x
		local oldy = new.y

		if direct == 'left' then
			new.x = new.x + 960
			direction = 180
			cond = function () return root.x <= -960 end
		elseif direct == 'right' then
			new.x = new.x - 960
			direction = 0
			cond = function () return root.x >= 960 end
		elseif direct == 'up' then
			new.y = new.y - 640
			direction = 90
			cond = function () return root.y >= 640 end
		elseif direct == 'down' then
			new.y = new.y + 640
			direction = 270
			cond = function () return root.y <= -640 end
		end

		root = create.layer() + Move { speed = speed, direction = direction }
		root.list[1] = old
		root.list[2] = new

		world.scene = root
		world.watch(cond, function ()
			new.x = oldx
			new.y = oldy
			world.set_scene(new)
			world.set_handle(new_handle)
			if callback then callback() end
		end)
	end
end

function M.find_e(e, name)
	if e.name == name then
		return e 
	end
	if e.list then
		for _,_e in ipairs(e.list) do
			local e = M.find_e(_e, name)
			if e then return e end
		end
	end
end


function M.create_world(...)
	return ecs.world(...)
		.add_system(Input())
		.add_system(Moving())
		.add_system(Render())
		.add_system(Debug())
end


return M