---------------------------------------------------------------
--
-- program manager
--
---------------------------------------------------------------
local kite = require "kite.core"
local core = require "program.core"
local matrix = require "matrix.core"

local M = {}

--
-- active program
--
local current 


local function active(id)
	if id ~= current then
		core.active(id)
		current = id
	end
	return id
end


local programs = {}

--------------------------------------------------------------
-- default program
--------------------------------------------------------------
function M.get_sprite_program()
	if programs['sprite'] then return programs['sprite'] end

	local soucre = require "kite.shader.sprite"
	local id = active(core.create(soucre.vs, soucre.fs))
	local mat_p = matrix.ortho(0, kite.window_width(), 0, kite.window_height(), -1, 1)

	-- props index
	local i_texture0 = core.uniform_location(id, "texture0")
	local i_projection = core.uniform_location(id, "projection")

	-- init
	core.uniform_1i(i_texture0, 0)
	core.uniform_matrix4fv(i_projection, mat_p)

	-- interface
	local self = {id = id}

	function self.active()
		active(id)
		return self
	end

	function self.set_projection(mat_p)
		assert(current == id)
		core.uniform_matrix4fv(i_projection, mat_p)
		return self
	end

	programs['sprite'] = self
	return self
end

--------------------------------------------------------------
-- your program
--------------------------------------------------------------






--------------------------------------------------------------


return M