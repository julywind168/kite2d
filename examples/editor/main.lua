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
local Miss = require 'kite.Miss'
local ecs = require 'ecs'
local Render = require 'ecs.systems.Render'
local Input = require 'ecs.systems.Input'
local Moving = require 'ecs.systems.Moving'
local Gravity = require 'ecs.systems.Gravity'
local Animation = require 'ecs.systems.Animation'
local Debug = require 'ecs.systems.Debug'

local seri = require 'seri'
local create = require 'ecs.functions'

-- local load_ok, flybird_entities = pcall(require, 'out.flybird_entities')


local file_head = "--[[\n"..[[
	@Time:	  %s
	@Author:  Kite Editor v0.01
]].."]]\n"


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


--
-- 编辑器现在 只能支持对已有的 entities 修改
-- 这个 函数 是从 flybird 中 copy来的 里面包含了 flybird 所需的全部 entity
--
local function create_flybird_entities()
	local canvas = create.canvas('canvas')
	
	local game_layer = create.layer()
	local ui_layer = create.layer({name = 'flybird_ui_layer'})


	for i=1,10 do
		local map = create.sprite{ texname='examples/assert/bg_day.png', x=180+(i-1)*360, y=320, w=360, h=640 }
		table.insert(game_layer.list, map)
	end

	for i=1,10 do
		local map = create.sprite{ texname='examples/assert/land.png', x=180+(i-1)*360, y=69, w=360, h=138 }
		table.insert(game_layer.list, map)		
	end

	for i=1,10 do
		local pipe_up = create.sprite{ texname='examples/assert/pipe_up.png', x=400+(i-1)*100, y=0, ay=0}
		local pipe_down = create.sprite{ texname='examples/assert/pipe_down.png', x=pipe_up.x+50, y=640, ay=1}
		table.insert(game_layer.list, pipe_up)
		table.insert(game_layer.list, pipe_down)
	end


	local button = create.button {name = 'play', texname = 'examples/assert/button_play.png', x=480, y=200 }
	local textfield = create.textfield {
		name = 'textfield',
		x = 480,
		y = 100,
		w = 200,
		h = 28,
		background = {color=0x333333aa},
		label = {color=0xffffffff, fontsize=24, text = 'NICK'}
	}

	local score = create.label {name='score', text='Score:0', x=10, y=630, ax=0, ay=1, color=0xcc4400ff, bordersize=1, bordercolor=0xeeee00ff}

	local bird = create.flipbook {
		name = 'bird',
		x = 480,
		y = 320,
		w = 48,
		h = 48,
		isloop = true,
		frames = {
			{texname='examples/assert/bird0_0.png'},
			{texname='examples/assert/bird0_1.png'},
			{texname='examples/assert/bird0_2.png'}
		}
	} + Move{speed = 0} + Mass{mass = 0} + Group{
		list = {create.label{text = 'NICK', x = 0, y = 34, fontsize = 20, bordersize=1}}
	}

	table.insert(game_layer.list, bird)


	ui_layer.list[1] = button
	ui_layer.list[2] = textfield
	ui_layer.list[3] = score

	canvas.list[1] = game_layer
	canvas.list[2] = ui_layer

	return canvas
end


local function create_editor_canvas(flybird_entities)
	
	local function create_hierarchy()
		local bg = create.sprite{ name='hierarchy', color=0x88888888, x=150, y=320-40, w=300, h=600} + Group() + SimpleDragg()
		bg.list[1] = create.sprite { x=0, y=300-32, ay=1, w=300-8, h=1, color = 0x22222288 }
		bg.list[2] = create.label { text = 'Hierarchy', x = 0, y = 300-2, ay = 1, fontsize = 28, color = 0x222222cc}


		bg.tag = 'editor'
		for _,e in ipairs(bg.list) do
			foreach(function (e)
				e.tag = 'editor'
				e.locked = true
			end, e)
		end
		return bg
	end

	local function create_inspector()
		local bg = create.sprite{ name='inspector', color=0x88888888, x =960-150, y=320-40, w=300, h=600 } + Group() + SimpleDragg()
		bg.list[1] = create.sprite { x=0, y=300-32, ay=1, w=300-8, h=1, color = 0x22222288 }
		bg.list[2] = create.label { text = 'Inspector', x = 0, y = 300-2, ay = 1, fontsize = 28, color = 0x222222cc}

		local content = create.sprite{color=0xdd888888, x=0, y=300-32-20, w=300-8,h=28}+Group{
			list = {
				create.label{text='my name', x=0,y=0, w=300-8, h=28, fontsize=24, color=0x00000088},
				create.label{text='x',x=-100,y=-33, w=300-8, h=30, fontsize=24, color=0x00000088},
				create.textfield{x=0,y=-33,w=100,h=30,background={color=0x333333aa},label={color=0xffffffff,text='10000',fontsize=24}},
				
				create.label{text='y',x=-100,y=-66, w=300-8, h=30, fontsize=24, color=0x00000088},
				create.textfield{x=0,y=-66,w=100,h=30,background={color=0x333333aa},label={color=0xffffffff,text='10000',fontsize=24}},

				create.label{text='w',x=-100,y=-99, w=300-8, h=30, fontsize=24, color=0x00000088},
				create.textfield{x=0,y=-99,w=100,h=30,background={color=0x333333aa},label={color=0xffffffff,text='10000',fontsize=24}},
				
				create.label{text='h',x=-100,y=-132, w=300-8, h=30, fontsize=24, color=0x00000088},
				create.textfield{x=0,y=-132,w=100,h=30,background={color=0x333333aa},label={color=0xffffffff,text='10000',fontsize=24}},
				
				create.label{text='ax',x=-100,y=-165, w=300-8, h=30, fontsize=24, color=0x00000088},
				create.textfield{x=0,y=-165,w=100,h=30,background={color=0x333333aa},label={color=0xffffffff,text='10000',fontsize=24}},
				
				create.label{text='ay',x=-100,y=-198, w=300-8, h=30, fontsize=24, color=0x00000088},
				create.textfield{x=0,y=-198,w=100,h=30,background={color=0x333333aa},label={color=0xffffffff,text='10000',fontsize=24}}
			}
		}

		bg.list[3] = content

		bg.tag = 'editor'
		for _,e in ipairs(bg.list) do
			foreach(function (e)
				e.tag = 'editor'
				e.locked = true
			end, e)
		end
		return bg	
	end

	local target = create.layer {
		name = 'LAYER(target)',
		list = { flybird_entities }
	}

	local editor = create.layer{
		name = 'LAYER(editor)',
		list = {create_hierarchy(), create_inspector()}
	}

	local canvas = create.layer {
		name = 'Canvas',
		list = {target, editor}
	}

	return canvas
end


local flybird_entities = load_ok and flybird_entities or create_flybird_entities()
local canvas = create_editor_canvas(flybird_entities)

local target = canvas.list[1]
local hierarchy = canvas.list[2].list[1]
local inspector = canvas.list[2].list[2]


dump(canvas)


local world = ecs.world(canvas)

local keyboard = world.keyboard
local mouse = world.mouse

local bird = world.find_entity('bird')

--
-- App data
--
local g = Miss { outfile = 'examples/editor/out/flybird_entities.lua' }

local handle = { click = {}, keydown = {}, keyup = {} }


local ins_mgr = inspector_manager(inspector, mouse, keyboard, handle)


-- ctrl + s
function handle.keydown.s()
	if keyboard.pressed['ctrl'] then
		local f = io.open(g.outfile, 'w')
		f:write(string.format(file_head, os.date('%Y/%m/%d %H:%M:%S')))
		f:write('return '..seri.pack(flybird_entities))
		f:close()
	end
end

-- show/hide hierarchy
function handle.keydown.h()
	hierarchy.active = not hierarchy.active
end

function handle.keydown.i()
	inspector.active = not inspector.active
end

world.set_handle(handle)
world.add_system(Input())
	.add_system(Moving())
	.add_system(Animation())
	.add_system(Render())


local game = {}

function game.update(dt)
	world('update', dt)
	ins_mgr.update()

	if keyboard.pressed['ctrl'] then return end

	if keyboard.pressed['w'] then
		local dist = math.floor(keyboard.pressed['w']/0.016/3)
		target.y = target.y - dist
		ins_mgr.on_eye_move('y', dist)
	elseif keyboard.pressed['a'] then
		local dist = -math.floor(keyboard.pressed['a']/0.016/3)
		target.x = target.x - dist
		ins_mgr.on_eye_move('x', dist)
	elseif keyboard.pressed['s'] then
		local dist = -math.floor(keyboard.pressed['s']/0.016/3)
		target.y = target.y - dist
		ins_mgr.on_eye_move('y', dist)
	elseif keyboard.pressed['d'] then
		local dist = math.floor(keyboard.pressed['d']/0.016/3)
		target.x = target.x - dist
		ins_mgr.on_eye_move('x', dist)
	end
end

function game.draw()
	world('draw')
end

function game.mouse(what, x, y, who)
	if who == 'left' then
		if what == 'press' then
			world('mousedown', x, y)
		else
			world('mouseup', x, y)
		end
	elseif who == 'right' then
		if what == 'press' then
			world('rmousedown', x, y)
		else
			world('rmouseup', x, y)
		end
	else
		world('mouse'..what, x, y)
	end
end

function game.keyboard(key, what)
	if what == 'press' then
		world('keydown', key)
	else
		world('keyup', key)
	end
end

function game.message(char)
	world('message', char)
end

function game.resume()
end

function game.pause()
end

function game.exit()
end

kite.start(game)