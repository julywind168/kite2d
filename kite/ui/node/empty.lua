local transform_attr = {x=true, y=true, xscale=true, yscale=true, angle=true}



return function (node, mt, proxy)

	setmetatable(proxy, {__index = node, __newindex = function (_, k, v)
		if node[k] then
			if transform_attr[k] then
				mt.modify[k] = v
			else
				error(k.." is read-only")
			end
		else
			rawset(proxy, k, v)
		end
	end})
end