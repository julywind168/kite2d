local audio = require "kite.manager.audio"


return function(self)


local circle1, circle2, circle3


function self.ready()
	circle1 = self.find("circle1")
	circle2 = self.find("circle2")
	circle3 = self.find("circle3")
end


function self.update(dt)
	circle1.angle = circle1.angle - 0.1
	circle2.angle = circle2.angle + 0.1
	circle3.angle = circle3.angle + 0.3
end


end