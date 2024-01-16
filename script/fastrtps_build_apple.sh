#!/bin/bash
#
# fastrtps_build_apple.sh
# Copyright © 2020 Dmitriy Borovikov. All rights reserved.
#

buildLibrary () {
local BUILD_DIR=$1
export PLATFORM_NAME=$2
export EFFECTIVE_PLATFORM_NAME=$3
export ARCHS=$4

echo "Build $PLATFORM_NAME$EFFECTIVE_PLATFORM_NAME $ARCHS"
local PROJECT_TEMP_DIR=$BUILD/temp/$BUILD_DIR
local BUILT_PRODUCTS_DIR=$BUILD/$BUILD_DIR
local LOG=$PROJECT_TEMP_DIR/build.log
echo "Build log: $LOG"

if [ -f "$BUILT_PRODUCTS_DIR/lib/libfastrtpsa.a" ]; then
echo Already build "$BUILT_PRODUCTS_DIR/lib/libfastrtpsa.a"
return
fi
#export CMAKE_BUILD_PARALLEL_LEVEL=$(sysctl hw.ncpu | awk '{print $2}')

rm -rf "$PROJECT_TEMP_DIR"
mkdir -p "$PROJECT_TEMP_DIR"
touch "$LOG"

if [ "$PLATFORM_NAME" = "macosx" ]; then
  if [ "$EFFECTIVE_PLATFORM_NAME" = "-maccatalyst" ]; then
cmake -S$SOURCE_DIR/memory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR" \
-D CMAKE_TOOLCHAIN_FILE=$ROOT_PATH/script/cmake/maccatalyst.toolchain.cmake \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-D CMAKE_DEBUG_POSTFIX="" \
-D CMAKE_OSX_DEPLOYMENT_TARGET="10.15" \
-D CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET="13.1" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-G Xcode \
>> "$LOG" 2>&1

xcodebuild build -scheme install -destination 'generic/platform=macOS,variant=Mac Catalyst' -project "$PROJECT_TEMP_DIR/memory/FOONATHAN_MEMORY.xcodeproj" \
>> "$LOG" 2>&1

cmake -S$SOURCE_DIR/Fast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR" \
-D CMAKE_TOOLCHAIN_FILE="$ROOT_PATH/script/cmake/maccatalyst.toolchain.cmake" \
-D foonathan_memory_DIR="$BUILT_PRODUCTS_DIR/lib/foonathan_memory/cmake" \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D COMPILE_TOOLS=OFF \
-D SHM_TRANSPORT_DEFAULT=OFF \
-D NO_TLS=ON \
-D BUILD_DOCUMENTATION=OFF \
-D BUILD_SHARED_LIBS=OFF \
-D CMAKE_OSX_DEPLOYMENT_TARGET="10.15" \
-D CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET="13.1" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-G Xcode \
>> "$LOG" 2>&1

xcodebuild build -scheme install -destination 'generic/platform=macOS,variant=Mac Catalyst' -project "$PROJECT_TEMP_DIR/Fast-DDS/fastrtps.xcodeproj" \
>> "$LOG" 2>&1

  else
cmake -S$SOURCE_DIR/memory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR" \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-D CMAKE_DEBUG_POSTFIX="" \
-D CMAKE_OSX_DEPLOYMENT_TARGET="10.10" \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-G Xcode \
>> "$LOG" 2>&1

cmake --build "$PROJECT_TEMP_DIR/memory" --config Release --target install \
>> "$LOG" 2>&1

cmake -S$SOURCE_DIR/Fast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR" \
-D foonathan_memory_DIR="$BUILT_PRODUCTS_DIR/lib/foonathan_memory/cmake" \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D COMPILE_TOOLS=OFF \
-D SHM_TRANSPORT_DEFAULT=OFF \
-D NO_TLS=ON \
-D TYPE_LONG_DOUBLE=8 \
-D BUILD_DOCUMENTATION=OFF \
-D BUILD_SHARED_LIBS=OFF \
-D CMAKE_OSX_DEPLOYMENT_TARGET="10.10" \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-G Xcode \
>> "$LOG" 2>&1

cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --config Release --target install \
>> "$LOG" 2>&1

  fi
fi

if [ "$PLATFORM_NAME" = "iphoneos" ] || [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
# iOS/simulator
export IPHONEOS_DEPLOYMENT_TARGET="12.0"
cmake -S$SOURCE_DIR/memory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_SYSTEM_NAME=iOS \
-D CMAKE_OSX_SYSROOT=$PLATFORM_NAME \
-D CMAKE_OSX_DEPLOYMENT_TARGET=$IPHONEOS_DEPLOYMENT_TARGET \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-D CMAKE_C_COMPILER=clang \
-D CMAKE_CXX_COMPILER=clang++ \
-D CMAKE_DEBUG_POSTFIX="" \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-G Xcode \
>> "$LOG" 2>&1

cmake --build "$PROJECT_TEMP_DIR/memory" --config Release --target install -- -sdk "$PLATFORM_NAME" \
>> "$LOG" 2>&1

cmake -S$SOURCE_DIR/Fast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_SYSTEM_NAME=iOS \
-D CMAKE_OSX_SYSROOT=$PLATFORM_NAME \
-D CMAKE_OSX_DEPLOYMENT_TARGET=$IPHONEOS_DEPLOYMENT_TARGET \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR" \
-D foonathan_memory_DIR="$BUILT_PRODUCTS_DIR/lib/foonathan_memory/cmake" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-D CMAKE_C_COMPILER=clang \
-D CMAKE_CXX_COMPILER=clang++ \
-D TYPE_LONG_DOUBLE=8 \
-D BUILD_SHARED_LIBS=NO \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D COMPILE_TOOLS=OFF \
-D SHM_TRANSPORT_DEFAULT=OFF \
-D NO_TLS=ON \
-D BUILD_DOCUMENTATION=OFF \
-G Xcode \
>> "$LOG" 2>&1

cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --config Release --target install -- -sdk "$PLATFORM_NAME" \
>> "$LOG" 2>&1

fi

if [ "$PLATFORM_NAME" = "xros" ] || [ "$PLATFORM_NAME" = "xrsimulator" ]; then

# xros/simulator
cmake -S$SOURCE_DIR/memory -B"$PROJECT_TEMP_DIR/memory" \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR" \
-D CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS="$PLATFORM_NAME" \
-D FOONATHAN_MEMORY_BUILD_EXAMPLES=OFF \
-D FOONATHAN_MEMORY_BUILD_TESTS=OFF \
-D FOONATHAN_MEMORY_BUILD_TOOLS=OFF \
-D CMAKE_DEBUG_POSTFIX="" \
-D CMAKE_SYSTEM_NAME=visionOS \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-G Xcode \
>> "$LOG" 2>&1

cmake --build "$PROJECT_TEMP_DIR/memory" --config Release --target install -- -sdk "$PLATFORM_NAME" \
>> "$LOG" 2>&1

cmake -S$SOURCE_DIR/Fast-DDS -B"$PROJECT_TEMP_DIR/Fast-DDS" \
-D CMAKE_INSTALL_PREFIX="$BUILT_PRODUCTS_DIR" \
-D foonathan_memory_DIR="$BUILT_PRODUCTS_DIR/lib/foonathan_memory/cmake" \
-D CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS="$PLATFORM_NAME" \
-D SQLITE3_SUPPORT=OFF \
-D THIRDPARTY=ON \
-D COMPILE_EXAMPLES=OFF \
-D COMPILE_TOOLS=OFF \
-D SHM_TRANSPORT_DEFAULT=OFF \
-D NO_TLS=ON \
-D BUILD_DOCUMENTATION=OFF \
-D BUILD_SHARED_LIBS=OFF \
-D CMAKE_SYSTEM_NAME=visionOS \
-D CMAKE_OSX_ARCHITECTURES="$ARCHS" \
-D CMAKE_CONFIGURATION_TYPES=Release \
-G Xcode \
>> "$LOG" 2>&1

cmake --build "$PROJECT_TEMP_DIR/Fast-DDS" --config Release --target install -- -sdk "$PLATFORM_NAME" \
>> "$LOG" 2>&1

fi

pushd "$BUILT_PRODUCTS_DIR/lib" > /dev/null
libtool -static -D -o libfastrtpsa.a libfastrtps.a libfastcdr.a libfoonathan_memory-0.7.3.a
popd > /dev/null
}
