unset(CMAKE_XCODE_ATTRIBUTE_INSTALL_PATH)

set(CMAKE_OSX_SYSROOT iphoneos)
set(CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS macosx)
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphonesimulator")
set(CMAKE_XCODE_ATTRIBUTE_SUPPORTS_MACCATALYST "YES")

set(CMAKE_CXX_FLAGS "-std=c++11 -Wno-shorten-64-to-32")
