#version 330
layout (location = 0) in vec2 pos;
layout (location = 1) in vec2 texcoord;

out vec2 v_texcoord;

uniform mat4 camera;

void main()
{
	gl_Position = camera * vec4(pos, 0.0, 1.0);	
	v_texcoord = texcoord;
}