--[[
	for examples/4-hello-editor -- 手工编写
]]
local ecs = require "ecs"

local Trans = require "ecs.d-components.Transform"
local Rect = require "ecs.d-components.Rectangle"
local Struct = require "ecs.d-components.Struct"

local Sprite = require "ecs.s-components.Sprite"
local Label = require "ecs.s-components.Label"
local Button = require "ecs.s-components.Button"
local TextField = require "ecs.s-components.TextField"

return {
	ecs.entity('bg') + Trans{x=480,y=320} + Rect{w=960,h=640} + Sprite{texname='examples/asset/bg.jpg'},
	ecs.entity('bird1') + Trans{x=480,y=320} + Rect{w=48,h=48} + Sprite{texname='examples/asset/bird0_0.png'},
	ecs.entity('bird2') + Trans{x=480,y=320+50} + Rect{w=48,h=48} + Sprite{texname='examples/asset/bird0_1.png'},
	ecs.entity('bird3') + Trans{x=480,y=320+100} + Rect{w=48,h=48} + Sprite{texname='examples/asset/bird0_2.png'},
	-- ecs.entity('button') + Trans{x=480,y=120} + Rect{w=80,h=28} + Sprite{texname='examples/asset/button_ok.png'} + Button()
}