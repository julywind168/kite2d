local M = {}


local function rotate(x0, y0, x1, y1, a)
	a = a * math.pi/180
	local x = (x1-x0)*math.cos(a) - (y1-y0)*math.sin(a) + x0
	local y = (x1-x0)*math.sin(a) + (y1-y0)*math.cos(a) + y0
	return x, y
end


function M.node_calc_aabb(node)
	local aabb = node.aabb

	aabb[1].x, aabb[1].y = node.x-node.anchor.x*node.width, node.y+(1-node.anchor.y)*node.height
	aabb[2].x, aabb[2].y = node.x-node.anchor.x*node.width, node.y-node.anchor.y*node.height
	aabb[3].x, aabb[3].y = node.x+(1-node.anchor.x)*node.width, node.y-node.anchor.y*node.height
	aabb[4].x, aabb[4].y = node.x+(1-node.anchor.x)*node.width, node.y+(1-node.anchor.y)*node.height

	aabb[1].x, aabb[1].y = rotate(node.x, node.y, aabb[1].x, aabb[1].y, node.angle)
	aabb[2].x, aabb[2].y = rotate(node.x, node.y, aabb[2].x, aabb[2].y, node.angle)
	aabb[3].x, aabb[3].y = rotate(node.x, node.y, aabb[3].x, aabb[3].y, node.angle)
	aabb[4].x, aabb[4].y = rotate(node.x, node.y, aabb[4].x, aabb[4].y, node.angle)
end

function M.node_in_aabb(node, x, y)
	local aabb = node.aabb
	if x < aabb[1].x or x > aabb[4].x then return false end
	if y > aabb[1].y or y < aabb[2].y then return false end
	return true
end


return M