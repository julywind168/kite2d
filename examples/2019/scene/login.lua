local create = require 'ecs.functions'

local self = create.canvas{name = 'Canvas'}

self.list = {
	create.sprite{x = 480, y = 320, w = 960, h = 640, texname = 'examples/assert/bg.jpg', color = 0xeeeeeeff },
	create.textfield{ 
		name = 'nick_textfield',
		x = 480,
		y = 160,
		w = 200,
		h = 32,
		background = {color = 0x333333aa},
		label = {color = 0xffffaaff, fontsize = 24, text = 'NICK'}
	},

	create.label{x = 480, y = 100, text = '按 enter 键开始游戏...', fontsize = 24, bordersize = 1}
}



return self