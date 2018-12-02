--[[
	@Time:	  2018/12/02 12:14:33
	@Author:  Editor v0.01
]]
local ecs = require "ecs"

local transform = require "ecs.d-components.Transform"
local rectangle = require "ecs.d-components.Rectangle"
local struct = require "ecs.d-components.Struct"

local sprite = require "ecs.s-components.Sprite"
local label = require "ecs.s-components.Label"
local button = require "ecs.s-components.Button"
local textField = require "ecs.s-components.TextField"


return {
ecs.entity('bg')+transform{x=480,y=320,sx=1.000000,sy=1.000000,angle=0}+rectangle{w=960,h=640,ax=0.500000,ay=0.500000}+sprite{active=true,camera=true,color=0xffffffff,texname='examples/asset/bg.jpg'},
ecs.entity('bird1')+transform{x=174,y=452,sx=1.000000,sy=1.000000,angle=0}+rectangle{w=48,h=48,ax=0.500000,ay=0.500000}+sprite{active=true,camera=true,color=0xffffffff,texname='examples/asset/bird0_0.png'},
ecs.entity('bird2')+transform{x=250,y=416,sx=1.000000,sy=1.000000,angle=0}+rectangle{w=48,h=48,ax=0.500000,ay=0.500000}+sprite{active=true,camera=true,color=0xffffffff,texname='examples/asset/bird0_1.png'},
ecs.entity('bird3')+transform{x=291,y=488,sx=1.000000,sy=1.000000,angle=0}+rectangle{w=48,h=48,ax=0.500000,ay=0.500000}+sprite{active=true,camera=true,color=0xffffffff,texname='examples/asset/bird0_2.png'}
}