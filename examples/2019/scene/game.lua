local create = require 'ecs.functions'

local self = create.canvas{name = 'Canvas'}

self.list = {
	create.sprite{x = 480, y = 320, w = 960, h = 640, color = 0x777777ff },

	create.label{x = 480, y = 100, text = '游戏开始...', fontsize = 24}
}



return self