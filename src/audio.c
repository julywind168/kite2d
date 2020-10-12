#include "audio.h"


static struct audio *audio = NULL;



void 
audio_destroy() {
	alcMakeContextCurrent(NULL);
	alcDestroyContext(audio->context);
	alcCloseDevice(audio->device);
	free(audio);
}


struct audio *
create_audio() {
	ALCdevice *device;
	ALCcontext *context;

	device = alcOpenDevice(NULL); if (!device) { LOG("no audio device\n"); return NULL; }
	context = alcCreateContext(device, NULL);
	if (!alcMakeContextCurrent(context)) {
		LOG("can't use current context\n");
		alcDestroyContext(context);
		alcCloseDevice(device);
		return NULL;
	}

	audio = malloc(sizeof(struct audio));
	audio->device = device;
	audio->context = context;
	
	audio->destroy = audio_destroy;
	return audio;
}