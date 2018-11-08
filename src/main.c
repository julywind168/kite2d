#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "game.h"


int main(int argc, char const *argv[])
{
	if (argc != 2) {
		fprintf(stderr, "usage fantasy.exe main.lua\n");
		return 1;
	}
	
	Game *game = create_game(argv[1]);
	if (game == NULL) {
		return 1;
	}
	
	game_start(game);
	destroy_game(game);
	printf("bye\n");
	return 0;
}