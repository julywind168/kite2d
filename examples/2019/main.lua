----------------------------------------------------------------------------------------
--
-- 第三个 demo, 这将是一个 MMORGP 
--
----------------------------------------------------------------------------------------
local kite = require 'kite'
local util = require 'util'
local timer = require 'kite.timer'
local audio = require 'kite.audio'
local miss = require 'kite.miss'

local login_scene = require 'scene.login'
local game_scene = require 'scene.game'
local world = util.create_world()




local game_layer = util.find_e(game_scene, 'LAYER(game)')
local hero = util.find_e(game_scene, 'hero')

local g = miss.create { nick = 'NICK', walk_speed = 180 }
	.bind('nick', util.find_e(login_scene, 'nick_textfield').label, 'text', util.find_e(game_scene, 'player_nick'), 'text')


-------------------------------------------------------------------------------
-- Login Scene
-------------------------------------------------------------------------------
local handle = { keydown = {}, keyup = {} }

function handle.keydown.escape()
	kite.exit()
end

function handle.keydown.down()
	hero.speed = g.walk_speed
	hero.direction = 270
	hero.cur_action = 'walk_down'
end

function handle.keydown.left()
	hero.speed = g.walk_speed
	hero.direction = 180
	hero.cur_action = 'walk_left'
end

function handle.keydown.up()
	hero.speed = g.walk_speed
	hero.direction = 90
	hero.cur_action = 'walk_up'
end

function handle.keydown.right()
	hero.speed = g.walk_speed
	hero.direction = 0
	hero.cur_action = 'walk_right'
end

function handle.keyup.down()
	hero.speed = 0
	hero.direction = 270
	hero.cur_action = 'stand_down'
end

function handle.keyup.left()
	hero.speed = 0
	hero.direction = 180
	hero.cur_action = 'stand_left'
end

function handle.keyup.up()
	hero.speed = 0
	hero.direction = 90
	hero.cur_action = 'stand_up'
end

function handle.keyup.right()
	hero.speed = 0
	hero.direction = 0
	hero.cur_action = 'stand_right'
end

local direction = {
	[0] = 'right',
	[90] = 'up',
	[180] = 'left',
	[270] = 'down'
}


function handle.keydown.a()
	local direct = direction[hero.direction]
	hero.cur_action = 'attack_'..direct
	
	audio.play_effect(hero, "examples/assert/music/attack.ogg")
end






local map = {0, 640-7*300, 300*13, 640}
local box = {w = 200, h = 132}

local camera = util.create_camera(game_layer, hero, map, application.window, box)

function handle.update()
	camera()
end

-------------------------------------------------------------------------------
-- Login Scene
-------------------------------------------------------------------------------
local login_handle = {}

function login_handle.keydown(key)
	if key == 'enter' then
		world.switch(game_scene, handle, util.switch.fade(1))
		audio.play_music("examples/assert/music/chuanqi_bg.ogg")
	end
end

world.set_scene(login_scene)
world.set_handle(login_handle)

kite.start(world.cb)