local ecs = require 'ecs'
local Render = require 'ecs.systems.Render'
local Input = require 'ecs.systems.Input'
local Moving = require 'ecs.systems.Moving'
local Gravity = require 'ecs.systems.Gravity'
local Animation = require 'ecs.systems.Animation'
local Debug = require 'ecs.systems.Debug'



local M = {}







function M.create_world(login_scene, handle)
	return ecs.world(login_scene, handle)
		.add_system(Input(handle))
		.add_system(Render())
		.add_system(Debug())
end



return M