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


local tmphover = nil
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
-- scroll
---------------------------------------------------------------------------
local function get_hover()
	local function f(root, e)
		return e.has['scroll_view'] and IN(mouse.x, mouse.y, root, e)
	end
	local result = {}

	world.eye_foreach(f, function (e)
		table.insert(result, e)
	end)
	return table.remove(result, #result)
end

function self.scroll(ox, oy)
	local hover = get_hover()
	if not hover or #hover.list == 0 then return end

	-- item 向上滚动
	if oy > 0 then
		local last = hover.list[#hover.list]
		local y2 = last.y - last.ay * last.h
		local bottom = 0 - hover.ay * hover.h
		if y2 < bottom then
			local step = math.floor(oy * last.h)
			if step > bottom - y2 then
				step = bottom - y2
			end

			for _,item in ipairs(hover.list) do
				item.y = item.y + step
			end
		end
	else
		local head = hover.list[1]
		local y4 = head.y + (1 - head.ay) * head.h
		local top = 0 + (1 - hover.ay) * hover.h
		if y4 > top then
			local step = math.floor(oy * head.h)
			if step < top - y4 then
				step = top - y4
			end

			for _,item in ipairs(hover.list) do
				item.y = item.y + step
			end
		end
	end
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
local on = { button = {}, textfield = {}, switch = {} }


-- switch
function on.switch.click(e)
	local current = e.current + 1
	if current > #e.frames then
		current = 1
	end
	e.current = current
	world('click', e, current)
end


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
	world('click', e.name)
end

function on.button.cancel(e)
	world('cancel', e.name)
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
			world('select')
		end
	else
		if tmpselected and tmpselected ~= e then
			on(tmpselected, 'lose_focus')
			tmpselected = nil
			world('select')
		end
		on(e, 'mousedown')
		tmppressed = e
		world('press', e)
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
			world('select', e)
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

	world('keydown', key)
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

	world('keyup', key)
end

return self

end

return function ()
	return function (world)
		return Input(world)
	end
end