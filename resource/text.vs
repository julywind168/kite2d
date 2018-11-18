#version 330 core
layout (location = 0) in vec4 vertex; // [pos, tex]

out vec2 texcoord;

uniform mat4 camera;

void main()
{
	gl_Position = camera * vec4(vertex.xy, 0.0, 1.0);
	
	//gl_Position = vec4(vertex.x/800, vertex.y/600, 0.0, 1.0);
	texcoord = vertex.zw;
}