local fantasy = require "fantasy"
local ecs = require "ecs"


local function in_box(e, x, y)
	local left_top = {}
	local right_bottom = {}

	left_top.x = e.x - e.w * e.ax
	left_top.y = e.y + e.h * (1-e.ay)

	right_bottom.x = left_top.x + e.w
	right_bottom.y = left_top.y - e.h

	if x < left_top.x or x > right_bottom .x then return false end
	if y > left_top.y or y < right_bottom.y then return false end
	return true
end

local function test(list, x, y)
	for _,e in ipairs(list) do
		if in_box(e, x, y) then
			return e
		end
	end
end

local file_meat = "--[[\n"..[[
	@Time:	  %s
	@Author:  Editor v0.01
]].."]]\n"

local file_head = [[
local ecs = require "ecs"

local transform = require "ecs.d-components.Transform"
local rectangle = require "ecs.d-components.Rectangle"
local struct = require "ecs.d-components.Struct"

local sprite = require "ecs.s-components.Sprite"
local label = require "ecs.s-components.Label"
local button = require "ecs.s-components.Button"
local textField = require "ecs.s-components.TextField"
]]


local seri = {}
function seri.transform(e)
	return string.format("+transform{x=%d,y=%d,sx=%f,sy=%f,angle=%d}", e.x, e.y, e.sx, e.sy, e.angle)
end
function seri.rectangle(e)
	return string.format("+rectangle{w=%d,h=%d,ax=%f,ay=%f}", e.w, e.h, e.ax, e.ay)
end
function seri.sprite(e)
	return string.format("+sprite{active=%s,camera=%s,color=%#x,texname='%s'}", 
		e.active, e.camera, e.color, e.texname)
end


local function write_entity(f, e, last_one)
	local text = string.format("ecs.entity('%s')", e.name)
	for _,name in ipairs(e.components) do
		local s = assert(seri[name], name)
		text = text .. s(e)
	end
	if not last_one then
		text = text .. ',\n'
	end
	f:write(text)
end


return function (world, filename)
			
	local g = world.g
	local g_mouse = g.mouse
	local list = {}
	local selected = nil
	local tip = nil
	local attach = false

	local function update_tip()
		tip.text = string.format('%s(%s): (%d, %d)',selected.name or 'no name', selected.id, selected.x, selected.y)
	end

	local function short(cmd, key)
		if cmd == 'ctrl' and key == 's' then
			local f = io.open(filename, 'w')
			f:write(string.format(file_meat, os.date('%Y/%m/%d %H:%M:%S')))
			f:write(file_head)
			f:write('\n\nreturn {\n')
			for i,e in ipairs(world.entities) do
				write_entity(f, e, i == #world.entities)
			end
			f:write('\n}')
			f:close()
		end
	end

	local self = {}

	function self.init()
		tip = assert(world.find_entity('__tip__'), 'no found \'__tip__\' entity')
		for i,e in ipairs(world.entities) do
			if e.name == '__tip__' then
				table.remove(world.entities, i)
				break
			end
		end
	end


	-- 类似Moba游戏的 移动视图
	local window = fantasy.window
	local camera = fantasy.camera()
	local step = 10

	function self.update(dt)
		if g_mouse.entered == false then
			if g_mouse.x < 200 then
				camera.x = camera.x - step
			elseif window.width - g_mouse.x< 200 then
				camera.x = camera.x + step
			elseif g_mouse.y < 200 then
				camera.y = camera.y - step
			elseif window.height - g_mouse.y < 200 then
				camera.y = camera.y + step 
			end
		end		
	end


	local pressed
	function self.keyboard(key, what)
		if what == 'press' then
			if pressed then
				short(pressed, key)
			end
			pressed = key
		else
			if selected then
				if key == 'up' then
					selected.y = selected.y + 1
					update_tip()
					return true
				elseif key == 'down' then
					selected.y = selected.y - 1
					update_tip()
					return true
				elseif key == 'left' then
					selected.x = selected.x - 1
					update_tip()
					return true
				elseif key == 'right' then
					selected.x = selected.x + 1
					update_tip()
					return true
				end
			end
			pressed = nil
		end
	end

	function self.mouse(what, x, y, who)

		-- 转换成世界坐标
		if x and y then
			x = camera.x + x - window.width/2
			y = camera.y + y - window.height/2
		end

		if what == 'move' then
			if attach then
				selected.x = x
				selected.y = y
				update_tip()
			end
			return
		end

		if who == 'right' then return end

		if what == 'press' then
			selected = test(list, x, y)
			if selected then
				attach = true
				update_tip()
				return true
			end
		else
			attach = false
		end
	end

	function self.ejoin(e)
		if e.draw then
			table.insert(list, 1, e)
		end
	end
	
	return setmetatable(self, {__call = function (_, event, ...)
		local f = self[event]
		if f then
			return f(...)
		end
	end})
end