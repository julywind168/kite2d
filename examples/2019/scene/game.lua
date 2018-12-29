local create = require 'ecs.functions'

local self = create.canvas{name = 'Canvas'}



local function create_map_layer()
	local layer = create.layer{ name = "LAYER(map)" }

	for i=1,7 do
		for j=1,13 do
			local file = "examples/2019/image/map/s1_"..(i-1).."_"..(j-1)..".jpg"
			local map = create.sprite {x = 150 + (j-1)*300, y = 640-150-(i-1)*300, w = 300, h = 300, texname = file }
			table.insert(layer.list, map)
		end
	end
	return layer
end

-- 主角, 怪物, 树木, 建筑 ...
local function create_moving_layer()
	local layer = create.layer{ name = "LAYER(moving)" }

	local hero = create.avatar{ name = "hero", x = 480, y = 320, ay = 0.5, w = 60, h = 160, cur_action = 'stand_down', actions = {
		stand_down = {
			frames = {
				{
					{texname='examples/2019/image/hero/walk/frame_00001.png'},
					{texname='examples/2019/image/arms/walk/frame_00001.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00002.png'},
					{texname='examples/2019/image/arms/walk/frame_00002.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00003.png'},
					{texname='examples/2019/image/arms/walk/frame_00003.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00004.png'},
					{texname='examples/2019/image/arms/walk/frame_00004.png'},
				},
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 1,
			timec = 0
		},
		stand_left = {
			frames = {
				{
					{texname='examples/2019/image/hero/walk/frame_00009.png'},
					{texname='examples/2019/image/arms/walk/frame_00009.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00010.png'},
					{texname='examples/2019/image/arms/walk/frame_00010.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00011.png'},
					{texname='examples/2019/image/arms/walk/frame_00011.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00012.png'},
					{texname='examples/2019/image/arms/walk/frame_00012.png'},
				},
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 1,
			timec = 0
		},
		stand_up = {
			frames = {
				{
					{texname='examples/2019/image/hero/walk/frame_00017.png'},
					{texname='examples/2019/image/arms/walk/frame_00017.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00018.png'},
					{texname='examples/2019/image/arms/walk/frame_00018.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00019.png'},
					{texname='examples/2019/image/arms/walk/frame_00019.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00020.png'},
					{texname='examples/2019/image/arms/walk/frame_00020.png'},
				},
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 1,
			timec = 0
		},
		stand_right = {
			frames = {
				{
					{texname='examples/2019/image/hero/walk/frame_00009.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00009.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00010.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00010.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00011.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00011.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00012.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00012.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 1,
			timec = 0
		},
		walk_down = {
			frames = {
				{
					{texname='examples/2019/image/hero/walk/frame_00021.png'},
					{texname='examples/2019/image/arms/walk/frame_00021.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00022.png'},
					{texname='examples/2019/image/arms/walk/frame_00022.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00023.png'},
					{texname='examples/2019/image/arms/walk/frame_00023.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00024.png'},
					{texname='examples/2019/image/arms/walk/frame_00024.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00025.png'},
					{texname='examples/2019/image/arms/walk/frame_00025.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00026.png'},
					{texname='examples/2019/image/arms/walk/frame_00026.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00027.png'},
					{texname='examples/2019/image/arms/walk/frame_00027.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00028.png'},
					{texname='examples/2019/image/arms/walk/frame_00028.png'},
				}
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 2,
			timec = 0
		},
		walk_left = {
			frames = {
				{
					{texname='examples/2019/image/hero/walk/frame_00037.png'},
					{texname='examples/2019/image/arms/walk/frame_00037.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00038.png'},
					{texname='examples/2019/image/arms/walk/frame_00038.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00039.png'},
					{texname='examples/2019/image/arms/walk/frame_00039.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00040.png'},
					{texname='examples/2019/image/arms/walk/frame_00040.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00041.png'},
					{texname='examples/2019/image/arms/walk/frame_00041.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00042.png'},
					{texname='examples/2019/image/arms/walk/frame_00042.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00043.png'},
					{texname='examples/2019/image/arms/walk/frame_00043.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00044.png'},
					{texname='examples/2019/image/arms/walk/frame_00044.png'},
				}
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 2,
			timec = 0
		},
		walk_up = {
			frames = {
				{
					{texname='examples/2019/image/hero/walk/frame_00053.png'},
					{texname='examples/2019/image/arms/walk/frame_00053.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00054.png'},
					{texname='examples/2019/image/arms/walk/frame_00054.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00055.png'},
					{texname='examples/2019/image/arms/walk/frame_00055.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00056.png'},
					{texname='examples/2019/image/arms/walk/frame_00056.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00057.png'},
					{texname='examples/2019/image/arms/walk/frame_00057.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00058.png'},
					{texname='examples/2019/image/arms/walk/frame_00058.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00059.png'},
					{texname='examples/2019/image/arms/walk/frame_00059.png'},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00060.png'},
					{texname='examples/2019/image/arms/walk/frame_00060.png'},
				}
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 2,
			timec = 0
		},
		walk_right = {
			frames = {
				{
					{texname='examples/2019/image/hero/walk/frame_00037.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00037.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00038.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00038.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00039.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00039.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00040.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00040.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00041.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00041.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00042.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00042.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00043.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00043.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				},
				{
					{texname='examples/2019/image/hero/walk/frame_00044.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/walk/frame_00044.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
				}
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 2,
			timec = 0
		},
		attack_down = {
			frames = {
				{
					{texname='examples/2019/image/hero/attack/frame_00001.png'},
					{texname='examples/2019/image/arms/attack/frame_00001.png'},
					{texname='examples/2019/image/effect/attack/frame_00001.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00002.png'},
					{texname='examples/2019/image/arms/attack/frame_00002.png'},
					{texname='examples/2019/image/effect/attack/frame_00002.png', y = -50}	
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00003.png'},
					{texname='examples/2019/image/arms/attack/frame_00003.png'},
					{texname='examples/2019/image/effect/attack/frame_00003.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00004.png'},
					{texname='examples/2019/image/arms/attack/frame_00004.png'},
					{texname='examples/2019/image/effect/attack/frame_00004.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00005.png'},
					{texname='examples/2019/image/arms/attack/frame_00005.png'},
					{texname='examples/2019/image/effect/attack/frame_00005.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00006.png'},
					{texname='examples/2019/image/arms/attack/frame_00006.png'},
					{texname='examples/2019/image/effect/attack/frame_00006.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00007.png'},
					{texname='examples/2019/image/arms/attack/frame_00007.png'},
					{texname='examples/2019/image/effect/attack/frame_00007.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00008.png'},
					{texname='examples/2019/image/arms/attack/frame_00008.png'},
					{texname='examples/2019/image/effect/attack/frame_00008.png', y = -50}
				}
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 2,
			timec = 0
		},
		attack_left = {
			frames = {
				{
					{texname='examples/2019/image/hero/attack/frame_00017.png'},
					{texname='examples/2019/image/arms/attack/frame_00017.png'},
					{texname='examples/2019/image/effect/attack/frame_00017.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00018.png'},
					{texname='examples/2019/image/arms/attack/frame_00018.png'},
					{texname='examples/2019/image/effect/attack/frame_00018.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00019.png'},
					{texname='examples/2019/image/arms/attack/frame_00019.png'},
					{texname='examples/2019/image/effect/attack/frame_00019.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00020.png'},
					{texname='examples/2019/image/arms/attack/frame_00020.png'},
					{texname='examples/2019/image/effect/attack/frame_00020.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00021.png'},
					{texname='examples/2019/image/arms/attack/frame_00021.png'},
					{texname='examples/2019/image/effect/attack/frame_00021.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00022.png'},
					{texname='examples/2019/image/arms/attack/frame_00022.png'},
					{texname='examples/2019/image/effect/attack/frame_00022.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00023.png'},
					{texname='examples/2019/image/arms/attack/frame_00023.png'},
					{texname='examples/2019/image/effect/attack/frame_00023.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00024.png'},
					{texname='examples/2019/image/arms/attack/frame_00024.png'},
					{texname='examples/2019/image/effect/attack/frame_00024.png', y = -50}
				}
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 2,
			timec = 0
		},
		attack_up = {
			frames = {
				{
					{texname='examples/2019/image/hero/attack/frame_00033.png'},
					{texname='examples/2019/image/arms/attack/frame_00033.png'},
					{texname='examples/2019/image/effect/attack/frame_00033.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00034.png'},
					{texname='examples/2019/image/arms/attack/frame_00034.png'},
					{texname='examples/2019/image/effect/attack/frame_00034.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00035.png'},
					{texname='examples/2019/image/arms/attack/frame_00035.png'},
					{texname='examples/2019/image/effect/attack/frame_00035.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00036.png'},
					{texname='examples/2019/image/arms/attack/frame_00036.png'},
					{texname='examples/2019/image/effect/attack/frame_00036.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00037.png'},
					{texname='examples/2019/image/arms/attack/frame_00037.png'},
					{texname='examples/2019/image/effect/attack/frame_00037.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00038.png'},
					{texname='examples/2019/image/arms/attack/frame_00038.png'},
					{texname='examples/2019/image/effect/attack/frame_00038.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00039.png'},
					{texname='examples/2019/image/arms/attack/frame_00039.png'},
					{texname='examples/2019/image/effect/attack/frame_00039.png', y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00040.png'},
					{texname='examples/2019/image/arms/attack/frame_00040.png'},
					{texname='examples/2019/image/effect/attack/frame_00040.png', y = -50}
				}
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 2,
			timec = 0
		},
		attack_right = {
			frames = {
				{
					{texname='examples/2019/image/hero/attack/frame_00017.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/attack/frame_00017.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/effect/attack/frame_00017.png', texcoord = {1,1, 1,0, 0,0, 0,1}, y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00018.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/attack/frame_00018.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/effect/attack/frame_00018.png', texcoord = {1,1, 1,0, 0,0, 0,1}, y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00019.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/attack/frame_00019.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/effect/attack/frame_00019.png', texcoord = {1,1, 1,0, 0,0, 0,1}, y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00020.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/attack/frame_00020.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/effect/attack/frame_00020.png', texcoord = {1,1, 1,0, 0,0, 0,1}, y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00021.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/attack/frame_00021.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/effect/attack/frame_00021.png', texcoord = {1,1, 1,0, 0,0, 0,1}, y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00022.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/attack/frame_00022.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/effect/attack/frame_00022.png', texcoord = {1,1, 1,0, 0,0, 0,1}, y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00023.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/attack/frame_00023.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/effect/attack/frame_00023.png', texcoord = {1,1, 1,0, 0,0, 0,1}, y = -50}
				},
				{
					{texname='examples/2019/image/hero/attack/frame_00024.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/arms/attack/frame_00024.png', texcoord = {1,1, 1,0, 0,0, 0,1}},
					{texname='examples/2019/image/effect/attack/frame_00024.png', texcoord = {1,1, 1,0, 0,0, 0,1}, y = -50}
				}
			},
			current = 1,
			pause = true,
			isloop = true,
			playspeed = 2,
			timec = 0
		},
	}} + Move{direction = 270}

	layer.list[1] = hero




	return layer
end


local function create_ui_layer()
	local layer = create.layer({ name = "LAYER(ui)", list = {
		create.label{name="player_nick", x = 20, y = 620, ax = 0, ay = 1,  text = 'NICK', fontsize = 24}
	}})

	return layer
end



self.list = {
	create.layer{name = 'LAYER(game)', list = {create_map_layer(), create_moving_layer()}},
	create_ui_layer(),
}


return self