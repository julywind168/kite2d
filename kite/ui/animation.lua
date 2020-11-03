local M = {}

local animation = {}



function M.create(node, params)
	local is_loop = params.is_loop == nil and true or params.is_loop

	local frames = assert(params.frames)
	local time = assert(params.time)

	local self = {
		sprite = node,
		active = true,
		time = time,
		frames = frames,
		frame_time = time/#frames,
		frame = 1,
		delta = 0,
		is_loop = is_loop
	}

	function self.pause()
		self.active = false
	end

	function self.resume()
		self.active = true
	end

	function self.destroy()
		animation[self] = nil
	end

	animation[self] = true
	return self
end


local function handle(m, dt)
	m.delta = m.delta + dt
	local delta = m.delta % m.time
	m.frame = delta//m.frame_time + 1

	local frame = m.frames[m.frame]
	for k,v in pairs(frame) do
		m.sprite[k] = v
	end

	if not m.is_loop and m.delta >= m.time then
		animation[m] = nil
		if m.on_complete then
			m.on_complete()
		end
	end
end


function M.update(dt)
	for m,_ in pairs(animation) do
		if m.active then
			handle(m, dt)
		end
	end
end



return M