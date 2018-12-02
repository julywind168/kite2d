local function Struct(e, t)
	local self = {}
	for _,e in ipairs(t) do
		self[e.name] = e
	end
	return self
end


return function (t)
	return function (e)
		return 'struct', Struct(e, t)
	end
end