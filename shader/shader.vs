#version 330

layout (location = 0) in vec2 pos;
layout (location = 1) in vec2 texcoord;

uniform mat4 transform;


out vec2 texcoord0;

void main() {
	gl_Position = transform * vec4(pos, 0.0, 1.0);
	texcoord0 = texcoord;
} 