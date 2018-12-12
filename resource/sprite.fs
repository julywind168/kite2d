#version 330

out vec4 frag_color;
in vec2 texcoord;


uniform sampler2D texture0;
uniform vec4 color;


void main() {
   	vec4 tmp = texture(texture0, texcoord);
   	frag_color.xyz = tmp.xyz * color.xyz;
   	frag_color.w = tmp.w;
   	frag_color *= color.w;
}