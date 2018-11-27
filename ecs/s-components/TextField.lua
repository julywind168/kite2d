local ecs = require "ecs"
local graphics = require "ecs.graphics"


return function (e)

	local world = ecs.current_world
	local bg, mask, label, cursor, limit

	local self = {}

	function self.init()
		bg = e.group.find('background')
		mask = e.group.find('mask')
		label = e.group.find('label')
		cursor = e.group.find('cursor')
		limit = mask.node.width
	end

	function self.start()
		label.node.anchor.x = 0
		label.node.x = mask.node.x - mask.node.width * mask.node.anchor.x
		cursor.node.anchor.x = 0
		cursor.node.active = false

		local mask_draw = mask.draw
		local label_draw = label.draw

		function mask.draw()
			graphics.start_stencil()
			mask_draw()
			graphics.stop_stencil()
		end

		function label.draw()
			label_draw()
			graphics.clear_stencil()
		end

		-- hook label.label (component)
		local _label = label.label

		local function set(k, v)
			if k == 'text' then
				_label.text = v
				if _label.width <= limit and label.node.anchor.x ~= 0 then
					label.node.anchor.x = 0
					label.node.x = mask.node.x - mask.node.width * mask.node.anchor.x
				elseif _label.width > limit and label.node.anchor.x ~= 1 then
					label.node.anchor.x = 1
					label.node.x = mask.node.x + mask.node.width * mask.node.anchor.x
				end
				cursor.node.x = label.node.x + (1-label.node.anchor.x) * label.label.width + 2
			else
				_label[k] = v
			end
		end

		label.label = setmetatable({}, {
				__index = _label,
				__pairs = function () return pairs(_label) end,
				__newindex = function (_,k,v) set(k, v) end
			})
	end


	local dealy = 0
	local dealy2 = 0
	function self.update(dt)
		if world.g.editing == e then
			dealy = dealy + dt
			if dealy > 0.5 then
				dealy = 0
				cursor.node.active = not cursor.node.active
			end

			dealy2 = dealy2 + dt
			if dealy2 > 0.05 then
				dealy2 = 0
				if world.g.keyboard.pressed == 'backspace' then
					local len = #label.label.text 
					if len > 0 then
						label.label.text = label.label.text:sub(1, len -1)
					end
				end
			end
		end
	end

	-- 进入编辑状态
	function self.active()
		cursor.node.x = label.node.x + (1-label.node.anchor.x) * label.label.width + 2
		cursor.node.active = true
		return e
	end

	-- 退出编辑状态
	function self.focus()
		cursor.node.active = false
	end

	function self.keyboard(key)
		if key == 'backspace' then
			local len = #label.label.text 
			if len > 0 then
				label.label.text = label.label.text:sub(1, len -1)
			end
		end
	end

	return 'textfield', self
end