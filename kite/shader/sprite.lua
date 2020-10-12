local kite = require "kite.core"

local vs = [[
#version 330 core
layout (location = 0) in vec2 apos;
layout (location = 1) in vec4 acolor;
layout (location = 2) in vec2 atexcoord;

out vec2 texcoord;
out vec4 color;

uniform mat4 projection;

void main()
{
	gl_Position = projection * vec4(apos, 0.0, 1.0);
	color = acolor;
	texcoord = atexcoord;
}
]]


local fs = [[
#version 330 core

out vec4 frag_color;
in vec2 texcoord;
in vec4 color;

uniform sampler2D texture0;


void main() {

	vec4 tmp = texture(texture0, texcoord);

	frag_color.xyz = tmp.xyz * color.xyz;
	frag_color.w = tmp.w;
	frag_color *= color.a;
}
]]


if kite.platform == "android" then
	vs = string.gsub(vs, "#version 330 core", "#version 300 es")
	fs = string.gsub(fs, "#version 330 core", "#version 300 es")
end


return {
	vs = vs,
	fs = fs
}