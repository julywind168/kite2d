# Makefile for platform.desktop with mingw

CFLAGS = -s -O1 -Wall
INCLUDE = -Isrc -Isrc/lib -I3rd -I3rd/glad -I3rd/glfw -I3rd/lua-5.4.0 -I3rd/openal -I3rd/stb
LINK = -L3rd/glfw -L3rd/lua-5.4.0 -lglfw3 -lgdi32 -lopengl32 -lopenal -llua54


SRC := \
	p.desktop/main.c \
	src/game.c \
	src/util.c \
	src/audio.c \
	src/renderer.c \


LUALIB := \
	src/lib/lkite.c \
	src/lib/lgraphics.c \
	src/lib/lsprite2d.c \
	src/lib/lmatrix.c \
	src/lib/lprogram.c \
	src/lib/laudio.c \


THIRD_PARTY := \
	3rd/glad/glad.c \
	3rd/stb/stb_vorbis.c \


.PHONY : kite


kite:
	gcc $(CFLAGS) $(INCLUDE) $(SRC) $(LUALIB) $(THIRD_PARTY) -o kite.exe $(LINK)