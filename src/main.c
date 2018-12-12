#include "common.h"
#include "game.h"



int main(int argc, char const *argv[])
{
	Game *g;
	if (argc != 2) {
		fprintf(stderr, "usage ./kite.exe 'gamedir'\n");
		return 1;
	}

	g = create_game(argv[1]);
	g->run();
	g->destroy();
	return 0;
}