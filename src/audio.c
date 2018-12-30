#include "audio.h"


static Audio *audio;




void 
audio_destroy() {
	alcMakeContextCurrent(NULL);
	alcDestroyContext(audio->context);
	alcCloseDevice(audio->device);
	free(audio);
}

Audio *
create_audio() {
	ALCdevice *device;
	ALCcontext *context;

	device = alcOpenDevice(NULL); if (!device) { printf("no audio device\n"); return NULL; }
	context = alcCreateContext(device, NULL);
	if (!alcMakeContextCurrent(context)) {
		printf("can't use current context\n");
		alcDestroyContext(context);
		alcCloseDevice(device);
		return NULL;
	}

	audio = malloc(sizeof(Audio));
	audio->device = device;
	audio->context = context;

	audio->destroy = audio_destroy;
	return audio;
}