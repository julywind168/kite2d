#include "lgraphics.h"
#include "game.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#include <math.h>


extern Game *G;


static int
lsprite_xy(lua_State *L)
{
    GLuint VBO;
    float xy[2];
    VBO = luaL_checkinteger(L, 1);
    xy[0] = luaL_checknumber(L, 2);
    xy[1] = luaL_checknumber(L, 3);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    for (int i = 0; i < 4; ++i) {
        glBufferSubData(GL_ARRAY_BUFFER, (i*9+2)*sizeof(float), 2*sizeof(float), &xy);
    }    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    return 0;
}


static int
lsprite_scale(lua_State *L)
{
    GLuint VBO;
    float scale[2];
    VBO = luaL_checkinteger(L, 1);
    scale[0] = luaL_checknumber(L, 2);
    scale[1] = luaL_checknumber(L, 3);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    for (int i = 0; i < 4; ++i) {
        glBufferSubData(GL_ARRAY_BUFFER, (i*9+4)*sizeof(float), 2*sizeof(float), &scale);
    }    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    return 0;
}


static int
lsprite_rotate(lua_State *L)
{
    GLuint VBO;
    float rotate;
    VBO = luaL_checkinteger(L, 1);
    rotate = luaL_checknumber(L, 2)*(M_PI/180);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    for (int i = 0; i < 4; ++i) {
        glBufferSubData(GL_ARRAY_BUFFER, (i*9+5)*sizeof(float), sizeof(float), &rotate);
    }
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    return 0;
}


static int
lsprite_texcoord(lua_State *L)
{
    GLuint VBO;
    float texcoord[8];
    VBO = luaL_checkinteger(L, 1);
    for (int i = 0; i < 8; ++i) {
        texcoord[i] = luaL_checknumber(L, i+2);
    }
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    for (int i = 0; i < 4; ++i) {
        glBufferSubData(GL_ARRAY_BUFFER, (i*9+7)*sizeof(float), 2*sizeof(float), &texcoord+i*2);
    }
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    return 0;
}


static int
lsprite(lua_State *L)
{
    float x, y, sx, sy, ro;
    float texcoord[8];
    GLuint EBO, VAO, VBO;

    x = luaL_checkinteger(L, 1);
    y = luaL_checkinteger(L, 2);
    sx = luaL_checknumber(L, 3);
    sy = luaL_checknumber(L, 4);
    ro = luaL_checknumber(L, 5) * (M_PI/180);

    texcoord[0] = luaL_optnumber(L, 6, 0.0f);
    texcoord[1] = luaL_optnumber(L, 7, 0.0f);

    texcoord[2] = luaL_optnumber(L, 8, 0.0f);
    texcoord[3] = luaL_optnumber(L, 9, 1.0f);
    
    texcoord[4] = luaL_optnumber(L, 10, 1.0f);
    texcoord[5] = luaL_optnumber(L, 11, 1.0f);
    
    texcoord[6] = luaL_optnumber(L, 12, 1.0f);
    texcoord[7] = luaL_optnumber(L, 13, 0.0f);


    float vertices[] = {
    //  direction     position   scale   rotate texcoord
        -1.0f,-1.0f,  x,y,       sx,sy,  ro,    texcoord[0],texcoord[1],
        -1.0f, 1.0f,  x,y,       sx,sy,  ro,    texcoord[2],texcoord[3],
         1.0f, 1.0f,  x,y,       sx,sy,  ro,    texcoord[4],texcoord[5],
         1.0f,-1.0f,  x,y,       sx,sy,  ro,    texcoord[6],texcoord[7]  
    };
    
    GLuint indices[] = {
        0,1,2,
        2,3,0
    };

    glGenVertexArrays(1, &VAO);
    glBindVertexArray(VAO);

    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);

    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    const static uint32_t step = 9 * sizeof(float);

    // direction
    glVertexAttribPointer(0,2,GL_FLOAT,GL_FALSE,step,NULL);
    glEnableVertexAttribArray(0);

    // transform
    glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,step,(void*)(2*sizeof(float)));
    glEnableVertexAttribArray(1);

    // scale
    glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,step,(void*)(4*sizeof(float)));
    glEnableVertexAttribArray(2);

    // rotate
    glVertexAttribPointer(3,1,GL_FLOAT,GL_FALSE,step,(void*)(6*sizeof(float)));
    glEnableVertexAttribArray(3);

    // texcoord
    glVertexAttribPointer(4,2,GL_FLOAT,GL_FALSE,step,(void*)(7*sizeof(float)));
    glEnableVertexAttribArray(4);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    lua_pushinteger(L, VAO);
    lua_pushinteger(L, VBO);
    return 2;
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
        {"sprite_xy", lsprite_xy},
        {"sprite_scale", lsprite_scale},
        {"sprite_rotate", lsprite_rotate},
        {"sprite_texcoord", lsprite_texcoord},
        {"sprite", lsprite},
        {"texture", ltexture},
        {"draw", ldraw},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}