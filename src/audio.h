#ifndef AUDIO_H
#define AUDIO_H

#include "common.h"
#include <AL/al.h>
#include <AL/alc.h>

#define STB_VORBIS_HEADER_ONLY
#include "stb_vorbis.c"

typedef struct
{
	ALCdevice *device;
	ALCcontext *context;
	void(*destroy)(void);
} Audio;





Audio *
create_audio();




#endif