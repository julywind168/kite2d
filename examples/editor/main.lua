----------------------------------------------------------------------------------------
--
-- 简单编辑器, 尝试修改某个 UI 的位置( 拖拽, 或者选中后在属性面板中修改 ) ctrl+s 保存后, 重启看是否编辑成功
--
-- tip: 选中物体后, 可以按方向键(up, donw, left, right) 以1像素的步长 调节物体的位置
-- tip: 可以按 'w' 'a' 's' 'd', 调节编辑器视野 (长按加速)
-- tip: 按 h 键可以 显示/隐藏 Hierarchy (层级面板), i 键 可以 显示/隐藏 Inspector (属性检查面板)
-- tip: 拖拽移动物体后, ctrl + z 可以撤销操作
-- tip: 鼠标按住某个物体, 这时候用 'w'/'a'/'s'/'d' 移动视野, 此物体会跟随视野移动
-- 
----------------------------------------------------------------------------------------
package.path = 'examples/?.lua;examples/?/init.lua;examples/editor/?.lua;' .. package.path
local kite = require 'kite'
local util = require 'util'
local seri = require 'seri'

---------------------------------------------------------------------------------
-- UTIL
---------------------------------------------------------------------------------
local file_head = "--[[\n"..[[
	@Time:	  %s
	@Author:  Kite Editor v0.02
]].."]]\n"

local function dump_2_file(filename, entities)
	local f = io.open(filename, 'w')
	f:write(string.format(file_head, os.date('%Y/%m/%d %H:%M:%S')))
	f:write('return '..seri.pack(entities))
	f:close()
end

local function foreach(f, e)
	f(e)

	if e.list then
		for _,e in ipairs(e.list) do
			foreach(f, e)
		end
	end
end

local function inspector_manager(inspector, mouse, keyboard, handle)
	local self = {}
	local selected = nil
	local editing = false
	local old = {}

	local content = inspector.list[3]
	local name = content.list[1]
	local x = content.list[3]
	local y = content.list[5]
	local w = content.list[7]
	local h = content.list[9]
	local ax = content.list[11]
	local ay = content.list[13]

	content.active = false

	function handle.keydown.up()
		if selected then
			selected.y = selected.y + 1
		end 
	end

	function handle.keydown.left()
		if selected then
			selected.x = selected.x - 1
		end 
	end

	function handle.keydown.down()
		if selected then
			selected.y = selected.y - 1
		end 
	end

	function handle.keydown.right()
		if selected then
			selected.x = selected.x + 1
		end 
	end

	function handle.keydown.z()
		if keyboard.pressed['ctrl'] then
			if selected then
				selected.x = old.x
				selected.y = old.y
			end
		end
	end

	function handle.press(e)
		if e.tag == 'editor' then
			editing = true
		else 
			editing = false
			selected = e
			old.x = e.x
			old.y = e.y
		end
	end

	function self.on_eye_move(key, dist)
		if mouse.pressed['left'] and selected then
			selected[key] = selected[key] + dist
		end
	end

	function self.update()
		if selected then
			local e = selected

			if editing then
				e.x = tonumber(x.label.text) or 0
				e.y = tonumber(y.label.text) or 0
				
				e.w = tonumber(w.label.text) or 0
				e.h = tonumber(h.label.text) or 0

				e.ax = tonumber(ax.label.text) or 0
				e.ay = tonumber(ay.label.text) or 0
			else
				content.active = true
				name.text = e.name
				x.label.text = tostring(e.x)
				y.label.text = tostring(e.y)

				w.label.text = tostring(e.w)
				h.label.text = tostring(e.h)

				ax.label.text = tostring(e.ax)
				ay.label.text = tostring(e.ay)
			end
		end
	end

	return self
end

---------------------------------------------------------------------------------
-- START
---------------------------------------------------------------------------------
local load_ok, _target = pcall(require, 'out.' .. TARGET)
local target = load_ok and _target or util.create_target(TARGET)

local canvas = util.create_editor_canvas(target)
local target_root = canvas.list[1]
local hierarchy = canvas.list[2].list[1]
local inspector = canvas.list[2].list[2]

local world = util.create_world(canvas)
local mouse = world.mouse
local keyboard = world.keyboard

-- Game data
local g = { outfile = 'examples/editor/out/'..TARGET..'.lua' }


local handle = { keydown = {} }

local ins_mgr = inspector_manager(inspector, mouse, keyboard, handle)


function handle.update(dt)
	ins_mgr.update(dt)

	if keyboard.pressed['ctrl'] then return end

	if keyboard.pressed['w'] then
		local dist = math.floor(keyboard.pressed['w']/0.016/3)
		target_root.y = target_root.y - dist
		ins_mgr.on_eye_move('y', dist)
	elseif keyboard.pressed['a'] then
		local dist = -math.floor(keyboard.pressed['a']/0.016/3)
		target_root.x = target_root.x - dist
		ins_mgr.on_eye_move('x', dist)
	elseif keyboard.pressed['s'] then
		local dist = -math.floor(keyboard.pressed['s']/0.016/3)
		target_root.y = target_root.y - dist
		ins_mgr.on_eye_move('y', dist)
	elseif keyboard.pressed['d'] then
		local dist = math.floor(keyboard.pressed['d']/0.016/3)
		target_root.x = target_root.x - dist
		ins_mgr.on_eye_move('x', dist)
	end
end

function handle.keydown.s()
	if keyboard.pressed['ctrl'] then
		dump_2_file(g.outfile, target)
	end
end

function handle.keydown.h()
	hierarchy.active = not hierarchy.active
end

function handle.keydown.i()
	inspector.active = not hierarchy.active
end


world.set_handle(handle)

kite.start(world.cb)