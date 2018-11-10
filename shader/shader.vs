#version 330

layout (location = 0) in vec2 direction;
layout (location = 1) in vec2 position;
layout (location = 2) in vec2 scale;
layout (location = 3) in float rotate;
layout (location = 4) in vec2 texcoord;

out vec2 texcoord0;


uniform uvec2 display;	// 屏幕宽高
uniform uvec2 camera;	// 相机位置


mat4 scale_mat = mat4(1.0);
mat4 trans_mat = mat4(1.0);
mat4 rota_mat = mat4(1.0);

void main() {
	
	scale_mat[0][0] = scale.x;
	scale_mat[1][1] = scale.y;

	trans_mat[0][3] = 2*(position.x - camera.x)/display.x;
	trans_mat[1][3] = 2*(position.y - camera.y)/display.y;

	rota_mat[0][0] = cos(rotate);
	rota_mat[0][1] = -sin(rotate);
	rota_mat[1][0] = sin(rotate);
	rota_mat[1][1] = cos(rotate);

	// 缩放 -> 旋转 -> 位移
	gl_Position =  vec4(direction, 0.0, 1.0) * scale_mat * rota_mat * trans_mat; 
	
	texcoord0 = texcoord;
} 