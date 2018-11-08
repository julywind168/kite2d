#version 330

out vec4 frag_color;
in vec3 color0;
in vec2 texcoord0;

uniform sampler2D tex1;
uniform sampler2D tex2;

void main() {
   	//frag_color = texture(tex1, texcoord0);
    frag_color = mix(texture(tex1, texcoord0), texture(tex2, texcoord0), 0.2);
}