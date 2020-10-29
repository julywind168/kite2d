--
-- I'm a label
--

local audio = require "kite.thread".query("audio")


return function(self)


local pause = true
local color = self.color

self.enabletouch()


function self.on_pressed()
	pause = not pause
	if not pause then
		audio.send("play_bgm")
	else
		-- audio.pause_music()
	end
end

function self.touch_ended()
	self.color = color
end

function self.touch_began()
	self.color = 0x00dd55ff
end


end