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

-- local flybird_entities = require 'out.flybird_entities'

local file_head = "--[[\n"..[[
	@Time:	  %s
	@Author:  Kite Editor v0.01
]].."]]\n"

--
-- 编辑器现在 只能支持对已有的 entities 修改
-- 这个 函数 是从 flybird 中 copy来的 里面包含了 flybird 所需的全部 entity
--
local function create_flybied_entities()
	local canvas = create.canvas('canvas')
	local system_resource = ecs.entity() + Group()
	system_resource.list[1] = create.keyboard()
	system_resource.list[2] = create.mouse()
	
	local map_layer = create.layer()
	local game_layer = create.layer()
	local ui_layer = create.layer()
	local main_camera = create.camera{name = 'main_camera'}
	local ui_camera = create.camera()


	for i=1,10 do
		local map = create.sprite{ texname='examples/assert/bg_day.png', x=180+(i-1)*360, y=320, w=360, h=640 }
		table.insert(map_layer.list, map)
	end

	for i=1,10 do
		local map = create.sprite{ texname='examples/assert/land.png', x=180+(i-1)*360, y=69, w=360, h=138 }
		table.insert(map_layer.list, map)		
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


	game_layer.list[1] = bird

	ui_layer.list[1] = button
	ui_layer.list[2] = textfield
	ui_layer.list[3] = score

	
	canvas.list[1] = system_resource

	-- main camera
	canvas.list[2] = main_camera
	canvas.list[3] = map_layer
	canvas.list[4] = game_layer

	-- ui camera
	canvas.list[5] = ui_camera
	canvas.list[6] = ui_layer

	return canvas
end


local function create_editor_layer()
	
	local function create_hierarchy()
		local bg = create.sprite{ color = 0x88888888, x = 150, y = 320-40, w = 300, h = 600} + Group() + SimpleDragg()
		bg.list[1] = create.sprite { x=0, y=300-32, ay=1, w=300-8, h=1, color = 0x22222288 }
		bg.list[2] = create.label { text = 'Hierarchy', x = 0, y = 300-2, ay = 1, fontsize = 28, color = 0x222222cc}

		return bg
	end

	local layer = create.layer('LAYER(Editor)')
	layer.list[1] = create_hierarchy()

	return layer
end


local flybird_entities = create_flybied_entities()
local editor_layer = create_editor_layer()
table.insert(flybird_entities.list, editor_layer)

local world = ecs.world(flybird_entities)

local keyboard = world.find_entity('keyboard')

local bird = world.find_entity('bird')

--
-- App data
--
local g = Miss { outfile = 'examples/editor/out/flybird_entities.lua' }

local handle = { click = {}, keydown = {}, keyup = {} }


-- ctrl + s
function handle.keydown.s()
	if keyboard.pressed['ctrl'] then

		local editor_layer = table.remove(flybird_entities.list, #flybird_entities.list)

		local f = io.open(g.outfile, 'w')
		f:write(string.format(file_head, os.date('%Y/%m/%d %H:%M:%S')))
		f:write('return '..seri.pack(flybird_entities))
		f:close()

		table.insert(flybird_entities.list, editor_layer)
	end
end

-- show/hide hierarchy
function handle.keydown.h()
	editor_layer.active = not editor_layer.active
end


world.add_system(Input(handle))
	.add_system(Moving())
	.add_system(Animation())
	.add_system(Render())


local game = {}

function game.update(dt)
	world('update', dt)
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