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
	local canvas = create.canvas{name = 'canvas'}
	
	local game_layer = create.layer{ name = 'layer(game)' }
	local ui_layer = create.layer{ name = 'layer(ui)' }

	-- game layer
	for i=1,10 do
		local map = create.sprite{ texname='examples/asset/bg_day.png', x=180+(i-1)*360, y=320, w=360, h=640 }
		table.insert(game_layer.list, map)
	end

	for i=1,10 do
		local map = create.sprite{ texname='examples/asset/land.png', x=180+(i-1)*360, y=69, w=360, h=138 }
		table.insert(game_layer.list, map)		
	end

	for i=1,10 do
		local pipe_up = create.sprite{ texname='examples/asset/pipe_up.png', x=400+(i-1)*100, y=0, ay=0}
		local pipe_down = create.sprite{ texname='examples/asset/pipe_down.png', x=pipe_up.x+50, y=640, ay=1}
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
			{texname='examples/asset/bird0_0.png'},
			{texname='examples/asset/bird0_1.png'},
			{texname='examples/asset/bird0_2.png'}
		}
	} + Move{speed = 0} + Mass{mass = 0} + Group{
		list = {create.label{text = 'NICK', x = 0, y = 34, fontsize = 20, bordersize=1}}
	}

	table.insert(game_layer.list, bird)

	-- ui layer
	local button = create.button {name = 'play', texname = 'examples/asset/button_play.png', x=480, y=200 }
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

--[[
container:

	item: lock, switch, label
		item1
		item2
	
]]

function M.create_editor_canvas(tagert_entities)

	local window = application.window
	
	local function create_hierarchy()
		local w = window.width/3 if w >=480 then w = 480 end
		local h = math.floor(w/0.618)

		local bg = create.sprite{ name='hierarchy', color=0x404035ff, x=w/2, y=window.height-100, ay=1, w=w, h=h} + Group() + SimpleDragg()
		bg.list[1] = create.sprite { x=0, y=-33, ay=1, w=w-16, h=1, ay=1, color = 0x999999ee }
		bg.list[2] = create.label { text = 'Hierarchy', x = 0, y = -2, ay = 1, fontsize = 28, color = 0xccccccff}

		local content = create.container{name='hierarchy content', x=8-w/2, y =-34-8, w=w-16, h=h-34-8*2, ay=1, ax=0, color = 0xffff0088}
			+ ScrollView()
			+ Layout{spacing_y = 2, padding_top=4, fixed = true}

		-- for i=1,20 do
		-- 	local item = create.label { text = 'item'..i, x = 0, y = 0 --[[-16-(i-1)*32]], fontsize = 28, color = 0xccccccff}
		-- 	table.insert(content.list, item)
		-- end

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

	local function create_inspector()
		local w = window.width/3 if w >=480 then w = 480 end
		local h = math.floor(w/0.618)

		local bg = create.sprite{ name='inspector', color=0x404035ff, x=window.width-w/2, y=window.height-100, ay=1, w=w, h=h } + Group() + SimpleDragg()
		bg.list[1] = create.sprite { x=0, y=-33, ay=1, w=w-16, h=1, color = 0x999999ee }
		bg.list[2] = create.label { text = 'Inspector', x = 0, y = -2, ay = 1, fontsize = 28, color = 0xccccccff}

		local content = create.sprite{color=0x404035ff, x=0, y=-34-8, w=w-16, h=h-34-8*2, ay=1}+Group{
			list = {
				create.label{text='my name', x=0, y=-19, w=w-16, h=28, fontsize=24, color=0xccccccff},
				create.label{text='x',x=-100,y=-19*3, w=w-16, h=30, fontsize=24, color=0xccccccff},
				create.textfield{x=0,y=-19*3,w=100,h=30,background={color=0x222222ff},label={color=0xddddddff,text='10000',fontsize=24}},
				
				create.label{text='y',x=-100, y=-19*5, w=w-16, h=30, fontsize=24, color=0xccccccff},
				create.textfield{x=0,y=-19*5,w=100,h=30,background={color=0x222222ff},label={color=0xddddddff,text='10000',fontsize=24}},

				create.label{text='w',x=-100,y=-19*7, w=w-16, h=30, fontsize=24, color=0xccccccff},
				create.textfield{x=0,y=-19*7,w=100,h=30,background={color=0x222222ff},label={color=0xddddddff,text='10000',fontsize=24}},
				
				create.label{text='h',x=-100,y=-19*9, w=w-16, h=30, fontsize=24, color=0xccccccff},
				create.textfield{x=0,y=-19*9,w=100,h=30,background={color=0x222222ff},label={color=0xddddddff,text='10000',fontsize=24}},
				
				create.label{text='ax',x=-100,y=-19*11, w=w-16, h=30, fontsize=24, color=0xccccccff},
				create.textfield{x=0,y=-19*11,w=100,h=30,background={color=0x222222ff},label={color=0xddddddff,text='10000',fontsize=24}},
				
				create.label{text='ay',x=-100,y=-19*13, w=w-16, h=30, fontsize=24, color=0xccccccff},
				create.textfield{x=0,y=-19*13,w=100,h=30,background={color=0x222222ff},label={color=0xddddddff,text='10000',fontsize=24}}
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
		list = {
			create_hierarchy(),
			create_inspector(),
		}
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