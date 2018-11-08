#version 330

out vec4 frag_color;
in vec2 texcoord0;

uniform sampler2D texture0;

void main() {
   	//frag_color = vec4(texcoord0.x, texcoord0.y, 1.0, 1.0);

	frag_color = texture(texture0, texcoord0);
    //frag_color = mix(texture(tex1, texcoord0), texture(tex2, texcoord0), 0.2);
}