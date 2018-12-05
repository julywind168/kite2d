--[[
	@Time:	  2018/12/02 12:14:33
	@Author:  Editor v0.01
]]
local ecs = require "ecs"

local Trans = require "ecs.d-components.Transform"
local Rect = require "ecs.d-components.Rectangle"

local sprite = require "ecs.s-components.Sprite"
local label = require "ecs.s-components.Label"
local button = require "ecs.s-components.Button"
local struct = require "ecs.s-components.Struct"
local textField = require "ecs.s-components.TextField"


return {
ecs.entity('bg')+Node{active=true}+Trans{x=480,y=320}+sprite{texname='examples/asset/bg.jpg'},
ecs.entity('bird1')+Node{active=true}+Trans{x=450,y=490}+sprite{texname='examples/asset/map/m1_2.jpg'},
ecs.entity('bird2')+Node{active=true}+Trans{x=750,y=490}+sprite{texname='examples/asset/map/m1_3.jpg'},
ecs.entity('bird3')+Node{active=true}+Trans{x=1050,y=490}+sprite{texname='examples/asset/map/m1_4.jpg'},
}