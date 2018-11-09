#include "lgraphics.h"
#include "game.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#include <math.h>


extern Game *G;


static int
lsprite(lua_State *L)
{
    uint32_t c;
    float x, y, w, h, r, g, b, a, xs, ys, ro;
    GLuint EBO, VAO, VBO;

    x = luaL_checknumber(L, 1);
    y = luaL_checknumber(L, 2);
    w = luaL_checknumber(L, 3);
    h = luaL_checknumber(L, 4);
    c = luaL_checkinteger(L, 5);
    xs = luaL_checknumber(L, 6);
    ys = luaL_checknumber(L, 7);
    ro = luaL_checknumber(L, 8) * (M_PI/180);

    r = (c>>24) & 0xFF;
    g = (c>>16) & 0xFF;
    b = (c>> 8) & 0xFF;
    a = (c>> 0) & 0xFF;

    float vertices[] = {
    //  direction     wh    texcoord    color     position  scale   rotate
        -1.0f,-1.0f,  w,h,  0.0f,0.0f,  r,g,b,a,  x,y,      xs,ys,  ro,
        -1.0f, 1.0f,  w,h,  0.0f,1.0f,  r,g,b,a,  x,y,      xs,ys,  ro,
         1.0f, 1.0f,  w,h,  1.0f,1.0f,  r,g,b,a,  x,y,      xs,ys,  ro,
         1.0f,-1.0f,  w,h,  1.0f,0.0f,  r,g,b,a,  x,y,      xs,ys,  ro
    };

    GLuint indices[] = {
        0,1,2,
        2,3,0
    };

    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);

    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    const static uint32_t step = 15 * sizeof(float);

    // direction
    glVertexAttribPointer(0,2,GL_FLOAT,GL_FALSE,step,NULL);
    glEnableVertexAttribArray(0);

    // wh
    glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,step,(void*)(2*sizeof(float)));
    glEnableVertexAttribArray(1);

    // texcoord
    glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,step,(void*)(4*sizeof(float)));
    glEnableVertexAttribArray(2);

    // color
    glVertexAttribPointer(3,4,GL_FLOAT,GL_FALSE,step,(void*)(6*sizeof(float)));
    glEnableVertexAttribArray(3);

    // position
    glVertexAttribPointer(4,2,GL_FLOAT,GL_FALSE,step,(void*)(10*sizeof(float)));
    glEnableVertexAttribArray(4);

    // scale
    glVertexAttribPointer(5,2,GL_FLOAT,GL_FALSE,step,(void*)(12*sizeof(float)));
    glEnableVertexAttribArray(5);

    // rotate
    glVertexAttribPointer(6,1,GL_FLOAT,GL_FALSE,step,(void*)(14*sizeof(float)));
    glEnableVertexAttribArray(6);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    lua_pushinteger(L, VAO);

    return 1;
}


static int
ltexture(lua_State *L)
{
    const char *filename = luaL_checkstring(L, 1);
    stbi_set_flip_vertically_on_load(true);

    GLuint texture;
    int width, height, channel;
    unsigned char *data = stbi_load(filename, &width, &height, &channel, 0);

    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
    stbi_image_free(data);
    glBindTexture(GL_TEXTURE_2D, 0);

    lua_pushinteger(L, texture);
    return 1;
}


static int
ldraw(lua_State *L) {
    GLuint vao, texture;
    vao = luaL_checkinteger(L, 1);
    texture = luaL_checkinteger(L, 2);

    glBindVertexArray(vao);
    glBindTexture(GL_TEXTURE_2D, texture);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    return 0;
}


int
lib_graphics(lua_State *L)
{
	luaL_Reg l[] = {
		{"sprite", lsprite},
        {"texture", ltexture},
        {"draw", ldraw},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}