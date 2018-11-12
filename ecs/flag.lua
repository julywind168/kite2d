local flag = {}

flag.Zero = 0x0

flag.Active = 0x1

flag.UI = 0x2




function flag.is_active(id)
	return id & flag.Active > 0
end


function flag.is_ui(id)
	return id & flag.UI > 0
end


return flag