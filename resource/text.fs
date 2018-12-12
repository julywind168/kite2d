#version 330 core
in vec2 texcoord;
out vec4 frag_color;

uniform sampler2D texture0;
uniform vec4 color;

void main()
{    
    vec4 sampled = vec4(1.0, 1.0, 1.0, texture(texture0, texcoord).r);
    frag_color = color * sampled;
}