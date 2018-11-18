#version 330 core
in vec2 texcoord;
out vec4 color;

uniform sampler2D texture0;
uniform vec4 textcolor;

void main()
{    
    vec4 sampled = vec4(1.0, 1.0, 1.0, texture(texture0, texcoord).r);
    color = textcolor * sampled;
}