--[[
	首先更新键盘状态, 处理UI, 然后是用户自定义控制逻辑
]]
local camera

local function IN(x, y, e)
	local x2 = e.x - e.ax * e.w * e.sx
	local y2 = e.y - e.ay * e.h * e.sy
	
	-- 转换成屏幕坐标
	if not e.has['TAG_UI_LAYER'] then
		x2 = x2 - camera.x
		y2 = y2 - camera.y
	end

	local x4 = x2 + e.w * e.sx
	local y4 = y2 + e.h * e.sy

	if x < x2 or x > x4 then return false end
	if y < y2 or y > y4 then return false end

	return true
end

local function TEST(x, y, entities)
	for _,e in ipairs(entities) do
		if IN(x, y, e) then
			return e
		end
	end
end


local function clock(tick, f)
	local time = 0

	return function (dt)
		time = time + dt
		if time >= tick then
			time = 0
			f()
		end
	end
end

--
-- Input system
--
local function Input(world, handle)

local self = {name='input'}

local function filter_buttons(e) return e.has['button'] and e.active end
local function filter_textfield(e) return e.has['textfield'] and e.active end


--
-- local
--
camera = world.find_entity('camera')
local keyboard = world.find_entity('keyboard')
local tmppressed = nil
local tmpselected = nil

local watchdog = clock(0.05, function ()
	if not tmpselected or tmpselected.type ~= 'textfield' then return end
	if keyboard.lpressed['backspace'] then
		local label = tmpselected.label
		local len = #label.text 
		if len > 0 then
			label.text = label.text:sub(1, utf8.offset(label.text, utf8.len(label.text))-1)
		end
	end
end)
---------------------------------------------------------------------------
-- update
---------------------------------------------------------------------------


function self.update(dt)
	for key,time in pairs(keyboard.pressed) do
		time = time + dt
		keyboard.pressed[key] = time
		if time >= 0.3 then
			keyboard.lpressed[key] = true
		end
	end

	-- textfield backspace
	watchdog(dt)
end


---------------------------------------------------------------------------
-- mouse
---------------------------------------------------------------------------
local function get_clickable()
	return world.get_entities(function (e)
		return e.has['TAG_CLICKABLE'] and e.active
	end)
end


local on = { button = {}, textfield = {} }

function on.button.mousedown(e)
	e.sx = e.sx * e.scale
	e.sy = e.sy * e.scale
end

function on.button.mouseup(e)
	e.sx = e.sx / e.scale
	e.sy = e.sy / e.scale
end

function on.button.click(e)
	local f = handle.click and handle.click[e.name]
	if f then f() end
end

function on.button.cancel(e)
	local f = handle.cancel and handle.cancel[e.name]
	if f then f() end	
end

function on.textfield.click(e)
	if not e.selected then
		e.selected = 0
		e.cursor.active = true
	end
end

function on.textfield.lose_focus(e)
	e.selected = nil
	e.cursor.active = false
end

setmetatable(on, {__call = function (_, e, event, ...)
	local f = on[e.type] and on[e.type][event]
	if f then
		f(e, ...)
	end
end})


function self.mousedown(x, y)
	local e = TEST(x, y, get_clickable())
	if not e then
		if tmpselected then
			on(tmpselected, 'lose_focus')
			tmpselected = nil
		end
	else
		if tmpselected and tmpselected ~= e then
			on(tmpselected, 'lose_focus')
			tmpselected = nil
		end
		on(e, 'mousedown')
		tmppressed = e
	end
end

function self.mouseup(x, y)
	local e = TEST(x, y, get_clickable())
	if e and e == tmppressed then
		on(e, 'mouseup')
		on(e, 'click')
		tmppressed = nil
		tmpselected = e
	else
		if tmppressed then
			on(tmppressed, 'mouseup')
			on(tmppressed, 'cancel')
			tmppressed = nil
		end
	end
end

---------------------------------------------------------------------------
-- textinput
---------------------------------------------------------------------------
function self.message(char)
	local e = tmpselected and tmpselected.type == 'textfield' and tmpselected
	if e then
		e.label.text = e.label.text..char
	end
end

---------------------------------------------------------------------------
-- keyborad
---------------------------------------------------------------------------
function self.keydown(key)
	keyboard.pressed[key] = 0

	local tf = tmpselected and tmpselected.type == 'textfield' and tmpselected
	if tf then return end

	local f = handle.keydown and handle.keydown[key]
	if f then f() end
end

function self.keyup(key)
	keyboard.pressed[key] = nil
	keyboard.lpressed[key] = nil

	local tf = tmpselected and tmpselected.type == 'textfield' and tmpselected
	if tf then
		if key == 'backspace' then
			local label = tf.label
			local len = #label.text 
			if len > 0 then
				label.text = label.text:sub(1, utf8.offset(label.text, utf8.len(label.text))-1)
			end
		end
		return
	end

	local f = handle.keyup and handle.keyup[key]
	if f then f() end
end

return self

end

return function (handle)
	return function (world)
		return Input(world, handle)
	end
end