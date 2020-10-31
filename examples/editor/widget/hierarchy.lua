--
-- 层级面板
--
return {
	name="hierarchy", type="sprite", x=-1920/2+200, y=0, width=400, height=600, image="image/white.png", color=0x404035ff,
	{type="label", x=0, y=280, width=100, height=30, text="Hierarchy", font="generic", size=28, color=0xccccccff},
	{type="sprite", x=0, y=256, width=380, height=1, image="image/white.png", color=0x999999ee},
	{name = "content", type="sprite", x=0, y=-20, width=380, height=540, image="image/white.png", color=0xffff0000},
}