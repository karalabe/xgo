# Go CGO cross compiler
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM ubuntu:14.04

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Create a small script to download binaries and validate their checksum
ENV FETCH ./fetch.sh
RUN \
  echo '#!/bin/bash'                   > $FETCH && \
  echo 'set -e'                       >> $FETCH && \
  echo 'file=`basename $1`'           >> $FETCH && \
  echo 'echo "Downloading $1..."'     >> $FETCH && \
  echo 'wget -q $1'                   >> $FETCH && \
  echo 'echo "$2  $file" > $file.sum' >> $FETCH && \
  echo 'sha1sum -c $file.sum'         >> $FETCH && \
  echo 'rm $file.sum'                 >> $FETCH && \
  chmod +x $FETCH


# Make sure apt-get is up to date and dependent packages are installed
RUN \
  apt-get update && \
  apt-get install -y automake autogen build-essential ca-certificates \
    gcc-arm-linux-gnueabi libc6-dev-armel-cross gcc-multilib gcc-mingw-w64 \
    clang llvm-dev  libtool libxml2-dev uuid-dev libssl-dev patch make \
    xz-utils cpio wget unzip git mercurial --no-install-recommends

# Configure the container for OSX cross compilation
ENV OSX_SDK_PATH https://github.com/trevd/android_platform_build2/raw/master/osxsdks10.6.tar.gz
ENV OSX_SDK      MacOSX10.6.sdk

RUN \
  git clone https://github.com/tpoechtrager/osxcross.git && \
  sed -i.bak s/read/#read/g /osxcross/build.sh && \
  \
  $FETCH $OSX_SDK_PATH f526b4ae9806e8d31e3b094e3f004f8f160a3fad && \
  tar -xzf `basename $OSX_SDK_PATH` --strip-components 1 SDKs/$OSX_SDK && \
  tar -cjf /osxcross/tarballs/$OSX_SDK.tar.bz2 $OSX_SDK && \
  rm -rf `basename $OSX_SDK_PATH` $OSX_SDK && \
  \
  /osxcross/build.sh


# Download the Go packages for each platform
ENV DIST_LINUX_64  http://golang.org/dl/go1.3.linux-amd64.tar.gz
ENV DIST_LINUX_32  http://golang.org/dl/go1.3.linux-386.tar.gz
ENV DIST_LINUX_ARM http://dave.cheney.net/paste/go.1.3.linux-arm~armv5-1.tar.gz
ENV DIST_OSX_64    http://golang.org/dl/go1.3.darwin-amd64-osx10.6.tar.gz
ENV DIST_OSX_32    http://golang.org/dl/go1.3.darwin-386-osx10.6.tar.gz
ENV DIST_WIN_64    http://golang.org/dl/go1.3.windows-amd64.zip
ENV DIST_WIN_32    http://golang.org/dl/go1.3.windows-386.zip

RUN \
  $FETCH $DIST_LINUX_64  b6b154933039987056ac307e20c25fa508a06ba6 && \
  $FETCH $DIST_LINUX_32  22db33b0c4e242ed18a77b03a60582f8014fd8a6 && \
  $FETCH $DIST_LINUX_ARM fc059c970a059757778b157b1140a3c56eb1a069 && \
  $FETCH $DIST_OSX_64    82ffcfb7962ca7114a1ee0a96cac51c53061ea05 && \
  $FETCH $DIST_OSX_32    159d2797bee603a80b829c4404c1fb2ee089cc00 && \
  $FETCH $DIST_WIN_64    1e4888e1494aed7f6934acb5c4a1ffb0e9a022b1 && \
  $FETCH $DIST_WIN_32    e4e5279ce7d8cafdf210a522a70677d5b9c7589d

# Install the core Linux package, inject and bootstrap the others
RUN \
  tar -C /usr/local -xzf `basename $DIST_LINUX_64` && \
  tar -C /usr/local --wildcards -xzf `basename $DIST_LINUX_32` go/pkg/linux_386* && \
  GOOS=linux GOARCH=386 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap -v && \
  tar -C /usr/local --wildcards -xzf `basename $DIST_LINUX_ARM` go/pkg/linux_arm* && \
  GOOS=linux GOARCH=arm /usr/local/go/pkg/tool/linux_amd64/dist bootstrap -v && \
  tar -C /usr/local --wildcards -xzf `basename $DIST_OSX_64` go/pkg/darwin_amd64* && \
  GOOS=darwin GOARCH=amd64 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap -v && \
  tar -C /usr/local --wildcards -xzf `basename $DIST_OSX_32` go/pkg/darwin_386* && \
  GOOS=darwin GOARCH=386 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap -v && \
  unzip -d /usr/local -q `basename $DIST_WIN_64` go/pkg/windows_amd64* && \
  GOOS=windows GOARCH=amd64 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap -v && \
  unzip -d /usr/local -q `basename $DIST_WIN_32` go/pkg/windows_386* && \
  GOOS=windows GOARCH=386 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap -v && \
  rm -f `basename $DIST_LINUX_64` `basename $DIST_LINUX_32` `basename $DIST_LINUX_ARM` \
    `basename $DIST_OSX_64` `basename $DIST_OSX_32` `basename $DIST_WIN_64` `basename $DIST_WIN_32`

ENV	PATH   /usr/local/go/bin:$PATH
ENV	GOPATH /go


# Create a small script to go get a package and cross compile it
ENV BUILD ./build.sh
RUN \
  echo '#!/bin/bash'                                                                    > $BUILD && \
  echo 'set -e'                                                                        >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Fetching $1...'                                                           >> $BUILD && \
  echo 'go get $1'                                                                     >> $BUILD && \
  echo 'cd $GOPATH/src/$1'                                                             >> $BUILD && \
  echo 'pack=`basename $1`'                                                            >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Compiling for linux/amd64...'                                             >> $BUILD && \
  echo 'GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -o $pack-linux-amd64'           >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Compiling for linux/386...'                                               >> $BUILD && \
  echo 'GOOS=linux GOARCH=386 CGO_ENABLED=1 go build -o $pack-linux-386'               >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Compiling for linux/arm...'                                               >> $BUILD && \
  echo 'CC=arm-linux-gnueabi-gcc \\'                                                 >> $BUILD && \
  echo '  GOOS=linux GOARCH=arm CGO_ENABLED=1 go build -o $pack-linux-arm'             >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Compiling for windows/amd64...'                                           >> $BUILD && \
  echo 'CC=x86_64-w64-mingw32-gcc \\'                                                  >> $BUILD && \
  echo '  GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go build -o $pack-windows-amd64.exe' >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Compiling for windows/386...'                                             >> $BUILD && \
  echo 'CC=i686-w64-mingw32-gcc \\'                                                    >> $BUILD && \
  echo '  GOOS=windows GOARCH=386 CGO_ENABLED=1 go build -o $pack-windows-386.exe'     >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Compiling for darwin/amd64...'                                            >> $BUILD && \
  echo '`/osxcross/target/bin/osxcross-env`'                                           >> $BUILD && \
  echo 'CC=o64-clang \\'                                                               >> $BUILD && \
  echo '  GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build -o $pack-darwin-amd64'       >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Compiling for darwin/386...'                                              >> $BUILD && \
  echo 'CC=o32-clang \\'                                                               >> $BUILD && \
  echo '  GOOS=darwin GOARCH=386 CGO_ENABLED=1 go build -o $pack-darwin-386'           >> $BUILD && \
  echo                                                                                 >> $BUILD && \
  echo 'echo Moving binaries to host...'                                               >> $BUILD && \
  echo 'cp `ls -t | head -n 7` /build'                                                 >> $BUILD && \
  chmod +x $BUILD

ENTRYPOINT ["./build.sh"]
