local M = {}

local animation = {}


--
-- params:{sprite, frames, time, is_loop, on_complete}
--
function M.create(self)
	if self.is_loop == nil then
		self.is_loop = true
	end

	self.active = true
	self.frame_time = self.time/#self.frames
	self.frame = 1
	self.delta = 0

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