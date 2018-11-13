local function SET(sprite, previous, next)
	sprite.previous = previous
	sprite.next = next
	return sprite
end

return function ()
	
	local head = {}
	local tail

	local self = {}
	
	function self.add(sprite)
		if tail == nil then
			head.next = sprite
			tail = sprite
		else
			if sprite.z >= tail.z then
				tail.next = SET(sprite, tail, nil)
				tail = tail.next
				return
			end

			local current = tail
			while true do
				local node = current.previous
				if not node then
					-- on the head
					head.next = SET(sprite, nil, head.next)
					break
				else
					if sprite.z >= node.z then
						-- after this node
						node.next = SET(sprite, node, node.next)
						break 
					else
						current = node
					end
				end
			end
		end
	end

	function self.update_z(sprite, z)
		if z > sprite.z then
			if sprite == tail or z < sprite.next.z then
				sprite.z = z
				return
			end

			local current = sprite
			while true do
				local node = current.next
				if not node then
					-- in the tail
					sprite.previous.next, sprite.next.previous = sprite.next, sprite.previous

					tail.next = sprite
					sprite.previous = tail
					tail = sprite
					tail.next = nil
					break
				else
					if node.z > z then
						sprite.previous.next, sprite.next.previous = sprite.next, sprite.previous

						-- before this node
						node.previous.next = sprite
						sprite.next = node
						sprite.previous = node.previous
						node.previous = sprite
						break
					else
						current = node
					end 
				end
			end
		else
			if sprite.previous == nil or sprite.previous.z <= z then
				sprite.z = z
				return
			end

			local current = sprite
			while true do
				local node = current.previous
				if not node then
					sprite.previous.next, sprite.next.previous = sprite.next, sprite.previous
					-- in the head

					head.next.previous = sprite
					sprite.next = head.next
					head.next = sprite
					sprite.previous = nil
					break
				else
					if node.z <= z then
						-- after this node
						sprite.previous.next, sprite.next.previous = sprite.next, sprite.previous

						node.next.previous = sprite
						sprite.next = node.next
						node.next = sprite
						sprite.previous = node
					else
						current = node
					end
				end
			end
		end
	end

	self.self = head

	return self
end