--
-- 属性查看编辑面板
--
return {
	name="inspector", type="sprite", x=1920/2-200, y=0, width=400, height=600, image="image/white.png", color=0x404035ff,
	{type="label", x=0, y=280, width=100, height=30, text="Inspector", font="generic", size=28, color=0xccccccff},
	{type="sprite", x=0, y=256, width=380, height=1, image="image/white.png", color=0x999999ee},

	-- name
	{name="name", type="label", x=0, y=230, width=100, height=30, text="name", font="generic", size=24, color=0xccccccff},
	
	-- x
	{type="label", xalign='right', x=-100, y=180, width=100, height=30, text="x", font="generic", size=24, color=0xccccccff},
	{name="input_x",type="textfield", x=30, y=180, width=180, height=32, text="", font="generic", size=24, bg_image = "image/white.png", cursor_image="image/white.png"},
	-- y
	{type="label", xalign='right', x=-100, y=130, width=100, height=30, text="y", font="generic", size=24, color=0xccccccff},
	{name="input_y",type="textfield", x=30, y=130, width=180, height=32, text="", font="generic", size=24, bg_image = "image/white.png", cursor_image="image/white.png"},
	
	-- width
	{type="label", xalign='right', x=-100, y=80, width=100, height=30, text="w", font="generic", size=24, color=0xccccccff},
	{name="input_w",type="textfield", x=30, y=80, width=180, height=32, text="", font="generic", size=24, bg_image = "image/white.png", cursor_image="image/white.png"},
	-- height
	{type="label", xalign='right', x=-100, y=30, width=100, height=30, text="h", font="generic", size=24, color=0xccccccff},
	{name="input_h",type="textfield", x=30, y=30, width=180, height=32, text="", font="generic", size=24, bg_image = "image/white.png", cursor_image="image/white.png"},
	
	-- xscale
	{type="label", xalign='right', x=-100, y=-20, width=100, height=30, text="xs", font="generic", size=24, color=0xccccccff},
	{name="input_xs",type="textfield", x=30, y=-20, width=180, height=32, text="", font="generic", size=24, bg_image = "image/white.png", cursor_image="image/white.png"},
	-- yscale
	{type="label", xalign='right', x=-100, y=-70, width=100, height=30, text="ys", font="generic", size=24, color=0xccccccff},
	{name="input_ys",type="textfield", x=30, y=-70, width=180, height=32, text="", font="generic", size=24, bg_image = "image/white.png", cursor_image="image/white.png"},
}
