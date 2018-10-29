# Go cross compiler (xgo): Base cross-compilation layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM ubuntu:17.10

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
    gcc-6-arm-linux-gnueabi g++-6-arm-linux-gnueabi libc6-dev-armel-cross                \
    gcc-6-arm-linux-gnueabihf g++-6-arm-linux-gnueabihf libc6-dev-armhf-cross            \
    gcc-6-aarch64-linux-gnu g++-6-aarch64-linux-gnu libc6-dev-arm64-cross                \
    gcc-6-mips-linux-gnu g++-6-mips-linux-gnu libc6-dev-mips-cross                       \
    gcc-6-mipsel-linux-gnu g++-6-mipsel-linux-gnu libc6-dev-mipsel-cross                 \
    gcc-6-mips64-linux-gnuabi64 g++-6-mips64-linux-gnuabi64 libc6-dev-mips64-cross       \
    gcc-6-mips64el-linux-gnuabi64 g++-6-mips64el-linux-gnuabi64 libc6-dev-mips64el-cross \
    gcc-6-multilib gcc-7-multilib g++-6-multilib gcc-mingw-w64 g++-mingw-w64 clang llvm-dev \
    libtool libxml2-dev uuid-dev libssl-dev swig openjdk-8-jdk pkg-config patch          \
    make xz-utils cpio wget zip unzip p7zip git mercurial bzr texinfo help2man cmake     \
    --no-install-recommends

# Fix any stock package issues
RUN ln -s /usr/include/asm-generic /usr/include/asm

# Add patches directory for patching later
ADD patches /patches

# Configure the container for OSX cross compilation
ENV OSX_SDK     MacOSX10.11.sdk
ENV OSX_NDK_X86 /usr/local/osx-ndk-x86

RUN \
  OSX_SDK_PATH=https://s3.dockerproject.org/darwin/v2/$OSX_SDK.tar.xz && \
  $FETCH $OSX_SDK_PATH dd228a335194e3392f1904ce49aff1b1da26ca62       && \
  tar -xf `basename $OSX_SDK_PATH` && rm -f `basename $OSX_SDK_PATH`

ADD patch.tar.xz $OSX_SDK/usr/include/c++

RUN tar -cf - $OSX_SDK/ | xz -c - > $OSX_SDK.tar.xz && rm -rf $OSX_SDK

RUN  \
  git clone https://github.com/tpoechtrager/osxcross.git && \
  mv  $OSX_SDK.tar.xz /osxcross/tarballs/        && \
  \
  sed -i -e 's|-march=native||g' /osxcross/build_clang.sh /osxcross/wrapper/build.sh && \
  UNATTENDED=yes OSX_VERSION_MIN=10.10 /osxcross/build.sh                             && \
  mv /osxcross/target $OSX_NDK_X86                                                   && \
  \
  rm -rf /osxcross

ENV PATH $OSX_NDK_X86/bin:$PATH

# Configure the container for iOS cross compilation
ENV IOS_NDK_ARM_7     /usr/local/ios-ndk-arm-7
ENV IOS_NDK_ARM64     /usr/local/ios-ndk-arm64
ENV IOS_SIM_NDK_AMD64 /usr/local/ios-sim-ndk-amd64

ADD update_ios.sh /update_ios.sh
ENV UPDATE_IOS /update_ios.sh
RUN chmod +x $UPDATE_IOS

RUN \
  IOS_SDK_FILE=iPhoneOS10.3.sdk.zip && \
  IOS_SDK_PATH=http://resources.airnativeextensions.com/ios/$IOS_SDK_FILE         && \
  $FETCH $IOS_SDK_PATH 7745815cd13d9b44c4cb0a2a40715e5410330233300ce4ff0ce106da17a636e8 && \
  mv `basename $IOS_SDK_PATH` iPhoneOS10.3.sdk.tmp.zip           && \
  $UPDATE_IOS /iPhoneOS10.3.sdk.tmp.zip                          && \
  rm -rf /iPhoneOS10.3.sdk.tmp.zip  && \
  cp -r /usr/local/osx-ndk-x86/SDK/MacOSX10.11.sdk/usr/include/c++/v1 /usr/local/ios-ndk-arm64/SDK/iPhoneOS10.3.sdk/usr/include/c++

ENV PATH $IOS_NDK_ARM64/bin:$PATH
ENV LD_LIBRARY_PATH $IOS_NDK_ARM64/lib/:$LD_LIBRARY_PATH

# Configure the container for Android cross compilation
ENV ANDROID_NDK         android-ndk-r13b
ENV ANDROID_NDK_PATH    http://dl.google.com/android/repository/$ANDROID_NDK-linux-x86_64.zip
ENV ANDROID_NDK_ROOT    /usr/local/$ANDROID_NDK
ENV ANDROID_NDK_LIBC    $ANDROID_NDK_ROOT/sources/cxx-stl/gnu-libstdc++/4.9
ENV ANDROID_PLATFORM    21
ENV ANDROID_CHAIN_ARM   arm-linux-androideabi-4.9
ENV ANDROID_CHAIN_ARM64 aarch64-linux-android-4.9
ENV ANDROID_CHAIN_AMD64 x86_64-4.9
ENV ANDROID_CHAIN_386   x86-4.9

RUN \
  $FETCH $ANDROID_NDK_PATH 0600157c4ddf50ec15b8a037cfc474143f718fd0 && \
  unzip `basename $ANDROID_NDK_PATH` \
    "$ANDROID_NDK/build/*"                                           \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/include/*"       \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi*/*" \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/arm64*/*"   \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/x86_64/*"   \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/x86/*"      \
    "$ANDROID_NDK/prebuilt/linux-x86_64/*"                           \
    "$ANDROID_NDK/platforms/*/arch-arm/*"                            \
    "$ANDROID_NDK/platforms/*/arch-arm64/*"                          \
    "$ANDROID_NDK/platforms/*/arch-x86_64/*"                         \
    "$ANDROID_NDK/platforms/*/arch-x86/*"                            \
    "$ANDROID_NDK/toolchains/llvm/*"                                 \
    "$ANDROID_NDK/toolchains/$ANDROID_CHAIN_ARM/*"                   \
    "$ANDROID_NDK/toolchains/$ANDROID_CHAIN_ARM64/*"                 \
    "$ANDROID_NDK/toolchains/$ANDROID_CHAIN_386/*"                   \
    "$ANDROID_NDK/toolchains/$ANDROID_CHAIN_AMD64/*" -d /usr/local > /dev/null && \
  rm -f `basename $ANDROID_NDK_PATH`

ENV PATH /usr/$ANDROID_CHAIN_ARM/bin:$PATH
ENV PATH /usr/$ANDROID_CHAIN_ARM64/bin:$PATH
ENV PATH /usr/$ANDROID_CHAIN_AMD64/bin:$PATH

# setup Android SDK tooling too
ENV ANDROID_SDK_PATH https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
ENV ANDROID_HOME /usr/local/android-sdk

RUN \
    $FETCH $ANDROID_SDK_PATH 92ffee5a1d98d856634e8b71132e8a95d96c83a63fde1099be3d86df3106def9 && \
    unzip `basename $ANDROID_SDK_PATH` \
        -d $ANDROID_HOME > /dev/null && \
    rm -f `basename $ANDROID_SDK_PATH` && \
    echo "Y" | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-21" "platforms;android-16"

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

# Setup gomobile helper script (note: gomobile itself will be fetched later with go)
ADD hacks /hacks
RUN chmod -R +x /hacks/*

ADD gomobile.sh /gomobile.sh
ENV GOMOBILE /gomobile.sh
RUN chmod +x $GOMOBILE

ENTRYPOINT ["/build.sh"]
