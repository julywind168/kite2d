#ifndef ASSET_HELPER_H
#define ASSET_HELPER_H

#include <android/asset_manager.h>




void copy_assets_on_first(AAssetManager *assetManager, const char *target_dir);

#endif
