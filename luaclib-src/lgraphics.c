#include "lgraphics.h"
#include "game.h"
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
/*
    default:    0,0, 0,1, 1,1, 1,0
    texcoord:   0,0, 0,1, 1,1, 1,0   

    1. width, height
    2. textureID
    3. texture_coord

*/
extern Game *G;

static int
lsprite(lua_State *L)
{
    GLuint EBO, VAO, VBO;

    float vertices[] = {
    //  position        texcoord
        0.0f, 0.0f,     0.0f, 0.0f,
        0.0f, 1.0f,     0.0f, 1.0f,
        1.0f, 1.0f,     1.0f, 1.0f,
        1.0f, 0.0f,     1.0f, 0.0f
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

    // pos
    glVertexAttribPointer(0,2,GL_FLOAT,GL_FALSE,4*sizeof(float),NULL);
    glEnableVertexAttribArray(0);

    // tex
    glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,4*sizeof(float),(void*)(2*sizeof(float)));
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    lua_pushinteger(L, VAO);
    return 1;
}


static int
ltexture(lua_State *L)
{
    const char *imagename = luaL_checkstring(L, 1);
    GLuint tx = loadbmp(imagename);
    if (tx == 0 || tx == 0xFFFFFFFF) {
        return 0;
    }

    lua_pushinteger(L, tx);
    return 1;
}


static int
ltexture2(lua_State *L)
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

    float transform[] = {
        1, 0, 0, -0.5,
        0, 1, 0, -0.5,
        0, 0, 1, 0,
        0, 0, 0, 1,
    };

    glUniformMatrix4fv(glGetUniformLocation(G->program, "transform"), 1, GL_TRUE, transform);


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
        {"texture2", ltexture},
        {"texture", ltexture2},
        {"draw", ldraw},
		{NULL, NULL}
	};
	luaL_newlib(L, l);
	return 1;
}