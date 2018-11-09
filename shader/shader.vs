#version 330

layout (location = 0) in vec2 direction;
layout (location = 1) in vec2 wh;
layout (location = 2) in vec2 texcoord;
layout (location = 3) in vec4 color;
layout (location = 4) in vec2 position;
layout (location = 5) in vec2 scale;
layout (location = 6) in float rotate;



uniform uvec2 display;	// (800, 600) 		屏幕宽高
uniform uvec2 camera; 	// (400, 300) 		相机位置


out vec2 texcoord0;

const vec4 default_v = vec4(0.0, 0.0, 0.0, 1.0);

void main() {


	// 位移
	mat4 trans_mat = mat4(1.0,  0.0,  0.0,  2*(position.x + scale.x*direction.x*wh.x/2 - camera.x)/display.x,
					  	  0.0,  1.0,  0.0,  2*(position.y + scale.y*direction.y*wh.y/2 - camera.y)/display.y,
					  	  0.0,  0.0,  1.0,  0.0,
					  	  0.0,  0.0,  0.0,  1.0);		 		

	// 旋转
	mat4 rota_mat = mat4(cos(rotate),  -sin(rotate),  0.0,  0.0,
					  	 sin(rotate),   cos(rotate),  0.0,  0.0,
					  	 		 0.0,           0.0,  1.0,  0.0,
					  	 		 0.0, 		    0.0,  0.0,  1.0);

	gl_Position = default_v * trans_mat * rota_mat;
	
	texcoord0 = texcoord;
} 