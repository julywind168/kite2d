local eye_foreach = eye_foreach

local function IN(x, y, root, e)
	local ex = root.x + e.x
	local ey = root.y + e.y
	local sx = root.sx * e.sx
	local sy = root.sy * e.sy
	local w = e.w * sx
	local h = e.h * sy

	local x2 = ex - e.ax * w
	local y2 = ey - e.ay * h

	if x < x2 or x > x2 + w then return false end
	if y < y2 or y > y2 + h then return false end
	return true
end


local function test(root, e, x, y, result)
	if (e.touchable or e.has['DRAGG'] or (MODE == 'EDITOR' and e.has['position'] and e.has['rectangle'])) and IN(x, y, root, e) then
		table.insert(result, e)
	end
end


local function TEST(x, y, entities)
	local result = {}
	eye_foreach(test, entities, x, y, result)
	return #result > 0 and result[#result] or nil
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
local function Input(world)

local self = {name='input'}

local tmppressed = nil
local tmpselected = nil
local mouse = world.mouse
local keyboard = world.keyboard

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

	watchdog(dt)
end


---------------------------------------------------------------------------
-- mouse move
---------------------------------------------------------------------------
function self.mousemove(x, y)
	if tmppressed and (tmppressed.has['DRAGG'] or MODE == 'EDITOR') then
		if tmppressed.locked then return end
		tmppressed.x = tmppressed.x + x - mouse.x
		tmppressed.y = tmppressed.y + y - mouse.y
	end

	mouse.x = x
	mouse.y = y
end


---------------------------------------------------------------------------
-- mouse touch
---------------------------------------------------------------------------
local on = { button = {}, textfield = {} }

-- button
function on.button.mousedown(e)
	e.sx = e.sx * e.scale
	e.sy = e.sy * e.scale
end

function on.button.mouseup(e)
	e.sx = e.sx / e.scale
	e.sy = e.sy / e.scale
end

function on.button.click(e)
	local f = world.handle.click and world.handle.click[e.name]
	if f then f() end
end

function on.button.cancel(e)
	local f = world.handle.cancel and world.handle.cancel[e.name]
	if f then f() end	
end

-- textfield
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
	local f = on[e.uitype] and on[e.uitype][event]
	if f then
		f(e, ...)
	end
end})


function self.mousedown(x, y)
	local e = TEST(x, y, world.scene)

	if not e then
		if tmpselected then
			on(tmpselected, 'lose_focus')
			tmpselected = nil
			local f = world.handle.select if f then f() end
		end
	else
		if tmpselected and tmpselected ~= e then
			on(tmpselected, 'lose_focus')
			tmpselected = nil
			local f = world.handle.select if f then f() end
		end
		on(e, 'mousedown')
		tmppressed = e
		if world.handle.press then world.handle.press(e) end
	end

	mouse.pressed['left'] = true
end

function self.mouseup(x, y)
	local e = TEST(x, y, world.scene)
	if e and e == tmppressed then
		on(e, 'mouseup')
		on(e, 'click')
		tmppressed = nil
		if tmpselected ~= e then
			tmpselected = e
			local f = world.handle.select if f then f(e) end
		end
	else
		if tmppressed then
			on(tmppressed, 'mouseup')
			on(tmppressed, 'cancel')
			tmppressed = nil
		end
	end

	mouse.pressed['left'] = nil 
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
	if tf then
		-- 其他键 忽略
		if key ~= 'backspace' and key ~= 'enter' then
			keyboard.pressed[key] = nil
		end
		return
	end

	local f = world.handle.keydown and world.handle.keydown[key]
	if f then f() end
end

function self.keyup(key)
	keyboard.pressed[key] = nil
	keyboard.lpressed[key] = nil
	keyboard.previous = key

	local tf = tmpselected and tmpselected.type == 'textfield' and tmpselected
	if tf then
		if key == 'backspace' then
			local label = tf.label
			local len = #label.text 
			if len > 0 then
				label.text = label.text:sub(1, utf8.offset(label.text, utf8.len(label.text))-1)
			end
		elseif key == 'enter' then
			tmpselected = nil
			tf.selected = nil
			tf.cursor.active = false
		end
		return
	end

	local f = world.handle.keyup and world.handle.keyup[key]
	if f then f() end
end

return self

end

return function ()
	return function (world)
		return Input(world)
	end
end