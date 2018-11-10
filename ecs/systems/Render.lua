local graphics = require "graphics.core"



--[[
	--system.render
	记录node 上次的信息
	draw 的时候检查属性是否变化

]]
return function()

	local self = {}

	local sprites = {}

	-- 事件处理
	local handler = {}

	function handler.draw()
		for _,sp in ipairs(sprites) do
			graphics.draw(sp('vao'), sp.sprite.texture)
		end
	end

	function handler.entity_join(e)
		if e.sprite then
			table.insert(sprites, e)
			table.sort(sprites, function ( a,b )
				return a.node.z < b.node.z
			end)
		end
	end

	function handler.entity_leave(e)
	end

	return setmetatable(self, {__call = function (_, event, ...)
		local f = handler[event]
		if f then
			return f(...)
		end
	end})
end