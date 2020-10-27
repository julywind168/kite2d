local sin = math.sin
local cos = math.cos
local PI = math.pi


local util = {}



function util.rotate(x0, y0, a, x1, y1)
	a = a * PI/180
	local x = (x1 - x0)*cos(a) - (y1 - y0)*sin(a) + x0
	local y = (x1 - x0)*sin(a) + (y1 - y0)*cos(a) + y0
	return x, y
end

function util.unpack(str)
    local func_str = "return "..str
    local func = loadstring(func_str)
    return func()
end

local function serialize(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ","
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do  
                lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ","
            end
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return "nil"
    elseif t == "userdata" then
        return "userdata"
    elseif t == "function" then
        return "function"
    elseif t == "thread" then
        return "thread"
    else
        error("can not serialize a " .. t .. " type.")
    end
    return lua
end


util.pack = serialize



return util