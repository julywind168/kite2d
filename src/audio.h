#ifndef AUDIO_H
#define AUDIO_H

#include "common.h"





struct audio
{
	ALCdevice *device;
	ALCcontext *context;

	void (*destroy)(void);
};





struct audio *
create_audio();




#endif