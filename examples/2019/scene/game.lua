local create = require 'ecs.functions'

local self = create.canvas{name = 'Canvas'}



local function create_map_layer()
	local layer = create.layer{ name = "LAYER(map)" }

	for i=1,3 do
		for j=1,4 do
			local file = "examples/assert/map/m"..i.."_"..j..".jpg"
			local map = create.sprite {x = 150 + (j-1)*300, y = 640-150-(i-1)*300, w = 300, h = 300, texname = file }
			table.insert(layer.list, map)
		end
	end
	return layer
end

-- 主角, 怪物, 树木, 建筑 ...
local function create_dynamic_layer()
	local layer = create.layer{ name = "LAYER(dynamic)" }
	return layer
end


local function create_ui_layer()
	local layer = create.layer({ name = "LAYER(ui)", list = {
		create.label{name="player_nick", x = 20, y = 620, ax = 0, ay = 1,  text = 'NICK', fontsize = 24}
	}})

	return layer
end



self.list = {
	create.layer{name = 'LAYER(game)', list = {create_map_layer(), create_dynamic_layer()}},
	create_ui_layer(),
}


return self