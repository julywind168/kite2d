local thread = require "kite.thread"
local audio = require "kite.manager.audio".init()

audio.load{"sound/bg.ogg"}

print("['audio'] bgm loaded")


local server = {}


function server.play_bgm()
	audio.play_music("sound/bg.ogg")
end


function server.exit()
	thread.exit()
	print("['audio'] bye")
end


thread.start(server)