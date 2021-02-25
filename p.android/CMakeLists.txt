#
# Copyright (C) The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#



cmake_minimum_required(VERSION 3.4.1)

# build native_app_glue as a static lib
set(${CMAKE_CXX_FLAGS}, "${CMAKE_CXX_FLAGS}")
add_library(native_app_glue STATIC
    ${ANDROID_NDK}/sources/android/native_app_glue/android_native_app_glue.c)

# now build app's shared lib
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -Wall -DLUA_USE_POSIX")

# Export ANativeActivity_onCreate(),
# Refer to: https://github.com/android-ndk/ndk/issues/381.
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -u ANativeActivity_onCreate")

add_library(lua54 SHARED
        3rd/lua-5.4.0/src/lapi.c
        3rd/lua-5.4.0/src/lauxlib.c
        3rd/lua-5.4.0/src/lbaselib.c
        3rd/lua-5.4.0/src/lcode.c
        3rd/lua-5.4.0/src/lcorolib.c
        3rd/lua-5.4.0/src/lctype.c
        3rd/lua-5.4.0/src/ldblib.c
        3rd/lua-5.4.0/src/ldebug.c
        3rd/lua-5.4.0/src/ldo.c
        3rd/lua-5.4.0/src/ldump.c
        3rd/lua-5.4.0/src/lfunc.c
        3rd/lua-5.4.0/src/lgc.c
        3rd/lua-5.4.0/src/linit.c
        3rd/lua-5.4.0/src/liolib.c
        3rd/lua-5.4.0/src/llex.c
        3rd/lua-5.4.0/src/lmathlib.c
        3rd/lua-5.4.0/src/lmem.c
        3rd/lua-5.4.0/src/loadlib.c
        3rd/lua-5.4.0/src/lobject.c
        3rd/lua-5.4.0/src/lopcodes.c
        3rd/lua-5.4.0/src/loslib.c
        3rd/lua-5.4.0/src/lparser.c
        3rd/lua-5.4.0/src/lstate.c
        3rd/lua-5.4.0/src/lstring.c
        3rd/lua-5.4.0/src/lstrlib.c
        3rd/lua-5.4.0/src/ltable.c
        3rd/lua-5.4.0/src/ltablib.c
        3rd/lua-5.4.0/src/ltm.c
        3rd/lua-5.4.0/src/lundump.c
        3rd/lua-5.4.0/src/lutf8lib.c
        3rd/lua-5.4.0/src/lvm.c
        3rd/lua-5.4.0/src/lzio.c
        )

#####################################################################
add_library(
        ex-common
        STATIC
        IMPORTED
)

set_target_properties(
        ex-common
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libex-common.a
)
#####################################################################

#####################################################################
add_library(
        openal
        STATIC
        IMPORTED
)

set_target_properties(
        openal
        PROPERTIES IMPORTED_LOCATION
        ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libopenal.a
)
#####################################################################
#set(CMAKE_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS} -lcommon -lopenal")

add_library(native-activity SHARED
        main.c
        asset_helper.c
        game.c
        util.c
        renderer.c
        audio.c
        charbuffer.c
        queue.c
        seri.c
        lib/lkite.c
        lib/lgraphics.c
        lib/lprogram.c
        lib/lmatrix.c
        lib/laudio.c
        lib/lsprite2d.c
        lib/lthread.c
        lib/lsharetable.c
        3rd/stb/stb_vorbis.c
        3rd/stb/stb_image.h
        )

target_include_directories(native-activity PRIVATE
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/lib
    ${CMAKE_SOURCE_DIR}/3rd/include
    ${CMAKE_SOURCE_DIR}/3rd/src
    ${CMAKE_SOURCE_DIR}/3rd/lua-5.4.0/src
    ${ANDROID_NDK}/sources/android/native_app_glue)

#link_directories("${CMAKE_SOURCE_DIR}/libs/arm64-v8a")

# add lib dependencies
target_link_libraries(native-activity
    lua54

    OpenSLES
    stdc++
    ex-common
    openal
    android
    native_app_glue
    GLESv3
    EGL
    log)
