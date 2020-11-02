local M = {}


local animation = {}


local function IN(t, o)
	for _,v in pairs(t) do
		if v == o then
			return true
		end
	end
end


function M.to(node, params)
	local time = assert(params.time)
	local delay = params.delay
	local on_complete = params.on_complete
	local attr = {}
	for k,v in pairs(params) do
		if not IN({"time", "delay", "on_complete"}, k) then
			attr[k] = {start = node[k], dest = v, speed = (v - node[k])/time}
		end
	end

	local self = {
		active = true,
		node = node,
		time = time,
		delay = params.delay,
		on_complete = params.on_complete,
		attr = attr
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
	local time = dt

	if m.delay then
		if dt >= m.delay then
			m.delay = nil
			time = dt - m.delay
		else
			m.delay = m.delay - dt
			time = nil
		end
	end

	if time then
		for k,a in pairs(m.attr) do
			m.node[k] = m.node[k] + a.speed * time
		end

		if time >= m.time then
			for k,a in pairs(m.attr) do
				m.node[k] = a.dest
			end
			animation[m] = nil

			if m.on_complete then
				m.on_complete()
			end
		else
			m.time = m.time - time
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