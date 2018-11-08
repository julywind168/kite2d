CFLAGS = -g -O0 -Wall -Isrc -Iluaclib-src -I3rd/include -L3rd/lib -Ilua
LINK = -lglfw3 -lgdi32 -lopengl32 

SRC := \
	src/main.c \
	src/game.c \
	src/util.c \


LUACLIB := \
	luaclib-src/lsystem.c \
	luaclib-src/lgraphics.c \

LUASRC := \
	lua/lapi.c \
	lua/lauxlib.c \
	lua/lbaselib.c \
	lua/lbitlib.c \
	lua/lcode.c \
	lua/lcorolib.c \
	lua/lctype.c \
	lua/ldblib.c \
	lua/ldebug.c \
	lua/ldo.c \
	lua/ldump.c \
	lua/lfunc.c \
	lua/lgc.c \
	lua/linit.c \
	lua/liolib.c \
	lua/llex.c \
	lua/lmathlib.c \
	lua/lmem.c \
	lua/loadlib.c \
	lua/lobject.c \
	lua/lopcodes.c \
	lua/loslib.c \
	lua/lparser.c \
	lua/lstate.c \
	lua/lstring.c \
	lua/lstrlib.c \
	lua/ltable.c \
	lua/ltablib.c \
	lua/ltm.c \
	lua/lundump.c \
	lua/lutf8lib.c \
	lua/lvm.c \
	lua/lzio.c

THIRD_PARTY := \
	3rd/src/glad.c \


.PHONY : fan


fan:
	gcc $(CFLAGS) $(SRC) $(LUACLIB) $(LUASRC) $(THIRD_PARTY) -o fan.exe $(LINK)