#version 330

out vec4 frag_color;
in vec2 texcoord0;

uniform sampler2D texture0;

uniform vec4 color;
uniform vec4 additive;


void main() {

   	vec4 tmp = texture(texture0, texcoord0);
   	frag_color.xyz = tmp.xyz * color.xyz;
   	frag_color.w = tmp.w;
   	frag_color *= color.w;
   	frag_color.xyz += additive.xyz * tmp.w;	
}