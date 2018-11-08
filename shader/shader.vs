#version 330

layout (location = 0) in vec3 pos;
layout (location = 1) in vec3 color;
layout (location = 2) in vec2 texcoord;

uniform mat4 transform;

out vec3 color0;
out vec2 texcoord0;

void main() {
	gl_Position = transform * vec4(pos, 1.0);
	color0 = color;
	texcoord0 = texcoord;
} 