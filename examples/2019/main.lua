----------------------------------------------------------------------------------------
--
-- 第三个 demo, 这将是一个 MMORGP 
--
----------------------------------------------------------------------------------------
local kite = require 'kite'
local util = require 'util'

local login_scene = require 'scene.login'
local game_scene = require 'scene.game'
local world = util.create_world()

-- game handle
local handle = {}

function handle.keydown(key)
	print('do nothing', key)
end


local login_handle = {}

function login_handle.keydown(key)
	if key == 'enter' then
		world.switch(game_scene, handle, util.switch.fade(1))
		-- world.switch(game_scene, handle, util.switch.slide('left', 1))
	end
end


world.set_scene(login_scene)
world.set_handle(login_handle)

kite.start(world.cb)