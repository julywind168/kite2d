--[[
	@Time:	  2018/12/02 12:14:33
	@Author:  Editor v0.01
]]
local ecs = require "ecs"

local Trans = require "ecs.d-components.Transform"
local Rect = require "ecs.d-components.Rectangle"
local struct = require "ecs.d-components.Struct"

local sprite = require "ecs.s-components.Sprite"
local label = require "ecs.s-components.Label"
local button = require "ecs.s-components.Button"
local textField = require "ecs.s-components.TextField"


return {
ecs.entity('m11')+Trans{x=150,y=490}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m1_1.jpg'},
ecs.entity('m12')+Trans{x=450,y=490}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m1_2.jpg'},
ecs.entity('m13')+Trans{x=750,y=490}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m1_3.jpg'},
ecs.entity('m14')+Trans{x=1050,y=490}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m1_4.jpg'},

ecs.entity('m21')+Trans{x=150,y=190}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m2_1.jpg'},
ecs.entity('m22')+Trans{x=450,y=190}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m2_2.jpg'},
ecs.entity('m23')+Trans{x=750,y=190}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m2_3.jpg'},
ecs.entity('m24')+Trans{x=1050,y=190}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m2_4.jpg'},

ecs.entity('m21')+Trans{x=150,y=-110}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m3_1.jpg'},
ecs.entity('m22')+Trans{x=450,y=-110}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m3_2.jpg'},
ecs.entity('m23')+Trans{x=750,y=-110}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m3_3.jpg'},
ecs.entity('m24')+Trans{x=1050,y=-110}+Rect{w=300,h=300}+sprite{texname='examples/asset/map/m3_4.jpg'},
}