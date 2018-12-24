----------------------------------------------------------------------------------------
--
-- 第三个 demo, 这将是一个 MMORGP 
--
----------------------------------------------------------------------------------------
local kite = require 'kite'
local util = require 'util'

local login_scene = require 'scene.login'
local game_scene = require 'scene.game'
local world

-- game handle
local handle = { keydown = {} }

function handle.keydown.enter()
	print('do nothing')
end


local login_handle = { keydown = {} }

function login_handle.keydown.enter()
	print('enter game ...')
	world.switch(game_scene)
	world.add_listener(handle)
end

world = util.create_world(login_scene, login_handle)

kite.start(world.cb)