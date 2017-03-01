# Go cross compiler (xgo): Base cross-compilation layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM ubuntu:16.04

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Mark the image as xgo enabled to support xgo-in-xgo
ENV XGO_IN_XGO 1


# Configure the Go environment, since it's not going to change
ENV PATH   /usr/local/go/bin:$PATH
ENV GOPATH /go


# Inject the remote file fetcher and checksum verifier
ADD fetch.sh /fetch.sh
ENV FETCH /fetch.sh
RUN chmod +x $FETCH


# Make sure apt-get is up to date and dependent packages are installed
RUN \
  apt-get update && \
  apt-get install -y automake autogen build-essential ca-certificates                    \
    gcc-5-arm-linux-gnueabi g++-5-arm-linux-gnueabi libc6-dev-armel-cross                \
    gcc-5-arm-linux-gnueabihf g++-5-arm-linux-gnueabihf libc6-dev-armhf-cross            \
    gcc-5-aarch64-linux-gnu g++-5-aarch64-linux-gnu libc6-dev-arm64-cross                \
    gcc-5-mips-linux-gnu g++-5-mips-linux-gnu libc6-dev-mips-cross                       \
    gcc-5-mipsel-linux-gnu g++-5-mipsel-linux-gnu libc6-dev-mipsel-cross                 \
    gcc-5-mips64-linux-gnuabi64 g++-5-mips64-linux-gnuabi64 libc6-dev-mips64-cross       \
    gcc-5-mips64el-linux-gnuabi64 g++-5-mips64el-linux-gnuabi64 libc6-dev-mips64el-cross \
    gcc-5-multilib g++-5-multilib gcc-mingw-w64 g++-mingw-w64 clang llvm-dev             \
    libtool libxml2-dev uuid-dev libssl-dev swig openjdk-8-jdk pkg-config patch          \
    make xz-utils cpio wget zip unzip p7zip git mercurial bzr texinfo help2man           \
    --no-install-recommends

# Fix any stock package issues
RUN ln -s /usr/include/asm-generic /usr/include/asm

# Configure the container for OSX cross compilation
ENV OSX_SDK     MacOSX10.11.sdk
ENV OSX_NDK_X86 /usr/local/osx-ndk-x86

RUN \
  OSX_SDK_PATH=https://s3.dockerproject.org/darwin/v2/$OSX_SDK.tar.xz && \
  $FETCH $OSX_SDK_PATH dd228a335194e3392f1904ce49aff1b1da26ca62       && \
  \
  git clone https://github.com/tpoechtrager/osxcross.git && \
  mv `basename $OSX_SDK_PATH` /osxcross/tarballs/        && \
  \
  sed -i -e 's|-march=native||g' /osxcross/build_clang.sh /osxcross/wrapper/build.sh && \
  UNATTENDED=yes OSX_VERSION_MIN=10.6 /osxcross/build.sh                             && \
  mv /osxcross/target $OSX_NDK_X86                                                   && \
  \
  rm -rf /osxcross

ADD patch.tar.xz $OSX_NDK_X86/SDK/$OSX_SDK/usr/include/c++
ENV PATH $OSX_NDK_X86/bin:$PATH

# Configure the container for iOS cross compilation
ENV IOS_NDK_ARM_7     /usr/local/ios-ndk-arm-7
ENV IOS_NDK_ARM64     /usr/local/ios-ndk-arm64
ENV IOS_SIM_NDK_AMD64 /usr/local/ios-sim-ndk-amd64

ADD update_ios.sh /update_ios.sh
ENV UPDATE_IOS /update_ios.sh
RUN chmod +x $UPDATE_IOS

RUN \
  IOS_SDK_PATH=https://sdks.website/dl/iPhoneOS9.3.sdk.tbz2     && \
  $FETCH $IOS_SDK_PATH db5ecf91617abf26d3db99e769bd655b943905e5 && \
  mv `basename $IOS_SDK_PATH` iPhoneOS9.3.sdk.tar.bz2           && \
  $UPDATE_IOS /iPhoneOS9.3.sdk.tar.bz2                          && \
  rm -rf /iPhoneOS9.3.sdk.tar.bz2

# Configure the container for Android cross compilation
ENV ANDROID_NDK         android-ndk-r11c
ENV ANDROID_NDK_PATH    http://dl.google.com/android/repository/$ANDROID_NDK-linux-x86_64.zip
ENV ANDROID_NDK_ROOT    /usr/local/$ANDROID_NDK
ENV ANDROID_NDK_LIBC    $ANDROID_NDK_ROOT/sources/cxx-stl/gnu-libstdc++/4.9
ENV ANDROID_PLATFORM    21
ENV ANDROID_CHAIN_ARM   arm-linux-androideabi-4.9
ENV ANDROID_CHAIN_ARM64 aarch64-linux-android-4.9
ENV ANDROID_CHAIN_386   x86-4.9

RUN \
  $FETCH $ANDROID_NDK_PATH de5ce9bddeee16fb6af2b9117e9566352aa7e279 && \
  unzip `basename $ANDROID_NDK_PATH` \
    "$ANDROID_NDK/build/*"                                           \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/include/*"       \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi*/*" \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/arm64*/*"   \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/x86/*"      \
    "$ANDROID_NDK/prebuilt/linux-x86_64/*"                           \
    "$ANDROID_NDK/platforms/*/arch-arm/*"                            \
    "$ANDROID_NDK/platforms/*/arch-arm64/*"                          \
    "$ANDROID_NDK/platforms/*/arch-x86/*"                            \
    "$ANDROID_NDK/toolchains/$ANDROID_CHAIN_ARM/*"                   \
    "$ANDROID_NDK/toolchains/$ANDROID_CHAIN_ARM64/*"                 \
    "$ANDROID_NDK/toolchains/$ANDROID_CHAIN_386/*" -d /usr/local > /dev/null && \
  rm -f `basename $ANDROID_NDK_PATH`

ENV PATH /usr/$ANDROID_CHAIN_ARM/bin:$PATH
ENV PATH /usr/$ANDROID_CHAIN_ARM64/bin:$PATH
ENV PATH /usr/$ANDROID_CHAIN_386/bin:$PATH

# Inject the old Go package downloader and tool-chain bootstrapper
ADD bootstrap.sh /bootstrap.sh
ENV BOOTSTRAP /bootstrap.sh
RUN chmod +x $BOOTSTRAP

# Inject the new Go root distribution downloader and bootstrapper
ADD bootstrap_pure.sh /bootstrap_pure.sh
ENV BOOTSTRAP_PURE /bootstrap_pure.sh
RUN chmod +x $BOOTSTRAP_PURE

# Inject the Go source distribution downloader and bootstrapper
ADD bootstrap_repo.sh /bootstrap_repo.sh
ENV BOOTSTRAP_REPO /bootstrap_repo.sh
RUN chmod +x $BOOTSTRAP_REPO

# Inject the C dependency cross compiler
ADD build_deps.sh /build_deps.sh
ENV BUILD_DEPS /build_deps.sh
RUN chmod +x $BUILD_DEPS

# Inject the container entry point, the build script
ADD build.sh /build.sh
ENV BUILD /build.sh
RUN chmod +x $BUILD

ENTRYPOINT ["/build.sh"]
