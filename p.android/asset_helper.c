#include <fcntl.h>
#include <errno.h>
#include <sys/stat.h>

#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>

#include "util.h"
#include "common.h"
#include "asset_list.h"


#define KI_ASSETS_LEN 9  //strlen("kt_assets") 


void copy_asset_file_to_dir(AAssetManager *assetManager, const char *target_dir, const char *dirname, const char *filename) {
    char filepath[256];
    char dir[256];
    AAsset *aAsset = NULL;
    FILE *file = NULL;
    if (strlen(dirname) == 0) {
        sprintf(filepath, "%s", filename);
    } else {
        sprintf(filepath, "%s/%s", dirname, filename);
    }

    aAsset = AAssetManager_open(assetManager, filepath, AASSET_MODE_BUFFER);
    if (aAsset == NULL) {
        LOG("can not found file:%s", filepath);
        return;
    }

    off_t sz = AAsset_getLength(aAsset);

    char *content = malloc(sz);
    int readsz = AAsset_read(aAsset, content, sz);
    assert(sz == readsz);
    AAsset_close(aAsset);

    if (strlen(dirname) == KI_ASSETS_LEN) {
        sprintf(filepath, "%s/%s", target_dir, filename);
    } else {
        sprintf(dir, "%s/%s", target_dir, dirname + KI_ASSETS_LEN + 1);
        mkdir(dir, S_IRWXU);
        sprintf(filepath, "%s/%s/%s", target_dir, dirname + KI_ASSETS_LEN + 1, filename);
    }

    file = fopen(filepath, "wb+");
    if (file == NULL) {
        LOG("can not open file:%s", filepath);
        fclose(file);
        return;
    }

    sz = fwrite(content, 1, sz, file);
    fclose(file);
    if (sz == 0) {
        LOG("copy file error:%s", strerror(errno));
    }

    LOG("copy file suc:%s %ld", filepath, sz);
}


void copy_asset_dir_to_dir(AAssetManager *assetManager, const char *target_dir, const char *dirname) {
    AAssetDir *assetdir = AAssetManager_openDir(assetManager, dirname);
    const char *filename;
    filename = AAssetDir_getNextFileName(assetdir);
    while (filename) {
        copy_asset_file_to_dir(assetManager, target_dir, dirname, filename);
        filename = AAssetDir_getNextFileName(assetdir);
    }
}

bool assets_flag_exist(const char *target_dir) {
    char filename[128];
    sprintf(filename, "%s/KITE_ASSET_FLAG", target_dir);
    if (access(filename, F_OK) == 0) {
        LOG("KITE_ASSET_EXIST");
        return true;
    } else {
        FILE *file = fopen(filename, "w");
        fclose(file);
        LOG("KITE_ASSET_NOT_EXIST");
        return false;
    }
}

void copy_assets_on_first(AAssetManager *assetManager, const char *target_dir) {
    if (assets_flag_exist(target_dir))
        return;
    int n = sizeof(ASSERT_DIR) / sizeof(ASSERT_DIR[0]);
    for (int i = 0; i < n; ++i) {
        copy_asset_dir_to_dir(assetManager, target_dir, ASSERT_DIR[i]);
    }
}
