# Go cross compiler (xgo): Base cross-compilation layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM ubuntu:15.10

MAINTAINER Péter Szilágyi <peterke@gmail.com>

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
  apt-get install -y automake autogen build-essential ca-certificates        \
    gcc-5-arm-linux-gnueabi g++-5-arm-linux-gnueabi libc6-dev-armel-cross    \
    gcc-5-multilib g++-5-multilib gcc-mingw-w64 g++-mingw-w64 clang llvm-dev \
    libtool libxml2-dev uuid-dev libssl-dev pkg-config patch make xz-utils   \
    cpio wget unzip p7zip git mercurial bzr --no-install-recommends && \
  ln -s /usr/include/asm-generic /usr/include/asm

# Configure the container for OSX cross compilation
ENV OSX_SDK_PATH    https://s3.amazonaws.com/andrew-osx-sdks/MacOSX10.9.sdk.tar.xz
ENV OSX_SDK         MacOSX10.9.sdk

RUN \
  git clone https://github.com/tpoechtrager/osxcross.git && \
  \
  $FETCH $OSX_SDK_PATH e2f01f6dc7611df4783d2adc279d15132f4e9851 && \
  mv `basename $OSX_SDK_PATH` /osxcross/tarballs/               && \
  \
  sed -i -e 's|-march=native||g' /osxcross/build_clang.sh /osxcross/wrapper/build.sh && \
  UNATTENDED=yes OSX_VERSION_MIN=10.6 /osxcross/build.sh

ENV PATH /osxcross/target/bin:$PATH

# Configure the container for Android cross compilation
ENV ANDROID_NDK       android-ndk-r10e
ENV ANDROID_NDK_PATH  http://dl.google.com/android/ndk/$ANDROID_NDK-linux-x86_64.bin
ENV ANDROID_NDK_ROOT  /usr/local/$ANDROID_NDK
ENV ANDROID_PLATFORM  21
ENV ANDROID_CHAIN_ARM arm-linux-androideabi-4.9

RUN \
  $FETCH $ANDROID_NDK_PATH c685e5f106f8daa9b5449d0a4f21ee8c0afcb2f6 && \
  7zr x `basename $ANDROID_NDK_PATH` \
    "$ANDROID_NDK/build"                                           \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/include"       \
    "$ANDROID_NDK/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi*" \
    "$ANDROID_NDK/prebuilt/linux-x86_64"                           \
    "$ANDROID_NDK/platforms/*/arch-arm"                            \
    "$ANDROID_NDK/toolchains/$ANDROID_CHAIN_ARM" -o/usr/local > /dev/null && \
  rm -f `basename $ANDROID_NDK_PATH`

ENV PATH /usr/$ANDROID_CHAIN_ARM/bin:$PATH

# Configure the container for iOS cross compilation
ENV IOS_SDK iPhoneOS8.1.sdk.tar.bz2
ENV IOS_SDK_PATH http://iphone.howett.net/sdks/dl/iPhoneOS8.1.sdk.tbz2
RUN \
  $FETCH $IOS_SDK_PATH 41203ed17a29743323cce0dd10b238efcea406e1       && \
  mv `basename $IOS_SDK_PATH` $IOS_SDK                                && \
  git clone https://github.com/tpoechtrager/cctools-port.git          && \
  /cctools-port/usage_examples/ios_toolchain/build.sh /$IOS_SDK armv7

ENV PATH /cctools-port/usage_examples/ios_toolchain/target/bin:$PATH

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
