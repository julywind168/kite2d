local ecs = require 'ecs'
local Render = require 'ecs.systems.Render'
local Input = require 'ecs.systems.Input'
local Moving = require 'ecs.systems.Moving'
local Gravity = require 'ecs.systems.Gravity'
local Animation = require 'ecs.systems.Animation'
local Debug = require 'ecs.systems.Debug'

local create = require 'ecs.functions'


local target = {}

function target.flybird()
	local canvas = create.canvas('canvas')
	
	local game_layer = create.layer()
	local ui_layer = create.layer()

	-- game layer
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

	-- ui layer
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

	ui_layer.list[1] = button
	ui_layer.list[2] = textfield
	ui_layer.list[3] = score

	canvas.list[1] = game_layer
	canvas.list[2] = ui_layer

	return canvas
end


local M = {}


function M.create_target(name)
	local f = assert(target[name], name)
	return f()
end


function M.create_editor_canvas(tagert_entities)
	
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
		list = { tagert_entities }
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


function M.create_world(...)
	return ecs.world(...)
		.add_system(Input())
		.add_system(Animation())
		.add_system(Moving())
		.add_system(Render())
end


return M