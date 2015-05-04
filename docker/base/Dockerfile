# Go cross compiler (xgo): Base cross-compilation layer
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
    clang llvm-dev  libtool libxml2-dev uuid-dev libssl-dev pkg-config \
    patch make xz-utils cpio wget unzip git mercurial --no-install-recommends

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
ENV PATH /osxcross/target/bin:$PATH


# Create a small script to download all the Go packages, install the core Linux
# package, inject and bootstrap the others
ENV BOOTSTRAP ./bootstrap.sh
RUN \
  echo '#!/bin/bash'                                                                                        > $BOOTSTRAP && \
  echo 'set -e'                                                                                            >> $BOOTSTRAP && \
  echo                                                                                                     >> $BOOTSTRAP && \
  echo '$FETCH $DIST_LINUX_64  $DIST_LINUX_64_SHA1'                                                        >> $BOOTSTRAP && \
  echo '$FETCH $DIST_LINUX_32  $DIST_LINUX_32_SHA1'                                                        >> $BOOTSTRAP && \
  echo '$FETCH $DIST_LINUX_ARM $DIST_LINUX_ARM_SHA1'                                                       >> $BOOTSTRAP && \
  echo '$FETCH $DIST_OSX_64    $DIST_OSX_64_SHA1'                                                          >> $BOOTSTRAP && \
  echo '$FETCH $DIST_OSX_32    $DIST_OSX_32_SHA1'                                                          >> $BOOTSTRAP && \
  echo '$FETCH $DIST_WIN_64    $DIST_WIN_64_SHA1'                                                          >> $BOOTSTRAP && \
  echo '$FETCH $DIST_WIN_32    $DIST_WIN_32_SHA1'                                                          >> $BOOTSTRAP && \
  echo                                                                                                     >> $BOOTSTRAP && \
  echo 'tar -C /usr/local -xzf `basename $DIST_LINUX_64`'                                                  >> $BOOTSTRAP && \
  echo                                                                                                     >> $BOOTSTRAP && \
  echo 'tar -C /usr/local --wildcards -xzf `basename $DIST_LINUX_32` go/pkg/linux_386*'                    >> $BOOTSTRAP && \
  echo 'GOOS=linux GOARCH=386 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap'                           >> $BOOTSTRAP && \
  echo 'tar -C /usr/local --wildcards -xzf `basename $DIST_LINUX_ARM` go/pkg/linux_arm*'                   >> $BOOTSTRAP && \
  echo 'GOOS=linux GOARCH=arm /usr/local/go/pkg/tool/linux_amd64/dist bootstrap'                           >> $BOOTSTRAP && \
  echo                                                                                                     >> $BOOTSTRAP && \
  echo 'tar -C /usr/local --wildcards -xzf `basename $DIST_OSX_64` go/pkg/darwin_amd64*'                   >> $BOOTSTRAP && \
  echo 'GOOS=darwin GOARCH=amd64 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap'                        >> $BOOTSTRAP && \
  echo 'tar -C /usr/local --wildcards -xzf `basename $DIST_OSX_32` go/pkg/darwin_386*'                     >> $BOOTSTRAP && \
  echo 'GOOS=darwin GOARCH=386 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap'                          >> $BOOTSTRAP && \
  echo                                                                                                     >> $BOOTSTRAP && \
  echo 'unzip -d /usr/local -q `basename $DIST_WIN_64` go/pkg/windows_amd64*'                              >> $BOOTSTRAP && \
  echo 'GOOS=windows GOARCH=amd64 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap'                       >> $BOOTSTRAP && \
  echo 'unzip -d /usr/local -q `basename $DIST_WIN_32` go/pkg/windows_386*'                                >> $BOOTSTRAP && \
  echo 'GOOS=windows GOARCH=386 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap'                         >> $BOOTSTRAP && \
  echo                                                                                                     >> $BOOTSTRAP && \
  echo 'rm -f `basename $DIST_LINUX_64` `basename $DIST_LINUX_32` `basename $DIST_LINUX_ARM` \\'           >> $BOOTSTRAP && \
  echo '  `basename $DIST_OSX_64` `basename $DIST_OSX_32` `basename $DIST_WIN_64` `basename $DIST_WIN_32`' >> $BOOTSTRAP && \
  chmod +x $BOOTSTRAP

ENV	PATH   /usr/local/go/bin:$PATH
ENV	GOPATH /go


# Create a small script to iterate over the dependencies and cross compile them
ENV BUILD_DEPS /build_deps.sh
RUN \
  echo '#!/bin/bash'                                                                                         > $BUILD_DEPS && \
  echo 'set -e'                                                                                              >> $BUILD_DEPS && \
  echo                                                                                                       >> $BUILD_DEPS && \
  echo 'rm -rf /deps-build && cp -r /deps /deps-build'                                                       >> $BUILD_DEPS && \
  echo 'for dep in `ls /deps-build`; do'                                                                     >> $BUILD_DEPS && \
  echo '  cd /deps-build/$dep && ./configure --disable-shared --host=$HOST --prefix=$PREFIX && make install' >> $BUILD_DEPS && \
  echo 'done'                                                                                                >> $BUILD_DEPS && \
  chmod +x $BUILD_DEPS


# Create a small script to go get a package and cross compile it
ENV BUILD ./build.sh
RUN \
  echo '#!/bin/bash'                                                                                                            > $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Fetching dependencies...'                                                                                         >> $BUILD && \
  echo 'mkdir /deps'                                                                                                           >> $BUILD && \
  echo 'DEPS=($DEPS) && for dep in "${DEPS[@]}"; do'                                                                           >> $BUILD && \
  echo '  echo Downloading $dep'                                                                                               >> $BUILD && \
  echo '  if [ "${dep##*.}" == "tar" ]; then wget $dep -O - | tar -C /deps -x; fi'                                             >> $BUILD && \
  echo '  if [ "${dep##*.}" == "gz" ]; then wget $dep -O - | tar -C /deps -xz; fi'                                             >> $BUILD && \
  echo '  if [ "${dep##*.}" == "bz2" ]; then wget $dep -O - | tar -C /deps -xj; fi'                                            >> $BUILD && \
  echo 'done'                                                                                                                  >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Fetching $1...'                                                                                                   >> $BUILD && \
  echo 'go get -d $1'                                                                                                          >> $BUILD && \
  echo 'cd $GOPATH/src/$1'                                                                                                     >> $BUILD && \
  echo 'export GOPATH=$GOPATH:`pwd`/Godeps/_workspace'                                                                         >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'if [ "$BRANCH" != "" ]; then'                                                                                          >> $BUILD && \
  echo '  if [ -d ".git" ]; then'                                                                                              >> $BUILD && \
  echo '    git checkout $BRANCH'                                                                                              >> $BUILD && \
  echo '  elif [ -d ".hg" ]; then'                                                                                             >> $BUILD && \
  echo '    hg checkout $BRANCH'                                                                                               >> $BUILD && \
  echo '  fi'                                                                                                                  >> $BUILD && \
  echo 'fi'                                                                                                                    >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'NAME=`basename $1/$PACK`'                                                                                              >> $BUILD && \
  echo 'if [ "$OUT" != "" ]; then'                                                                                             >> $BUILD && \
  echo '  NAME=$OUT'                                                                                                           >> $BUILD && \
  echo 'fi'                                                                                                                    >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'if [ "$FLAG_V" == "true" ]; then V=-v; fi'                                                                             >> $BUILD && \
  echo 'if [ "$FLAG_RACE" == "true" ]; then R=-race; fi'                                                                       >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Compiling for linux/amd64...'                                                                                     >> $BUILD && \
  echo 'HOST=x86_64-linux PREFIX=/usr/local $BUILD_DEPS'                                                                       >> $BUILD && \
  echo 'GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go get -d ./$PACK'                                                               >> $BUILD && \
  echo 'GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build $V $R -o $NAME-linux-amd64$R ./$PACK'                                   >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Compiling for linux/386...'                                                                                       >> $BUILD && \
  echo 'HOST=i686-linux PREFIX=/usr/local $BUILD_DEPS'                                                                         >> $BUILD && \
  echo 'GOOS=linux GOARCH=386 CGO_ENABLED=1 go get -d ./$PACK'                                                                 >> $BUILD && \
  echo 'GOOS=linux GOARCH=386 CGO_ENABLED=1 go build $V -o $NAME-linux-386 ./$PACK'                                            >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Compiling for linux/arm...'                                                                                       >> $BUILD && \
  echo 'CC=arm-linux-gnueabi-gcc HOST=arm-linux PREFIX=/usr/local/arm $BUILD_DEPS'                                             >> $BUILD && \
  echo 'CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm CGO_ENABLED=1 GOARM=5 go get -d ./$PACK'                                >> $BUILD && \
  echo 'CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm CGO_ENABLED=1 GOARM=5 go build $V -o $NAME-linux-arm ./$PACK'           >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Compiling for windows/amd64...'                                                                                   >> $BUILD && \
  echo 'CC=x86_64-w64-mingw32-gcc HOST=x86_64-w64-mingw32 PREFIX=/usr/x86_64-w64-mingw32 $BUILD_DEPS'                          >> $BUILD && \
  echo 'CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go get -d ./$PACK'                                   >> $BUILD && \
  echo 'CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go build $V $R -o $NAME-windows-amd64$R.exe ./$PACK' >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Compiling for windows/386...'                                                                                     >> $BUILD && \
  echo 'CC=i686-w64-mingw32-gcc HOST=i686-w64-mingw32 PREFIX=/usr/i686-w64-mingw32 $BUILD_DEPS'                                >> $BUILD && \
  echo 'CC=i686-w64-mingw32-gcc GOOS=windows GOARCH=386 CGO_ENABLED=1 go get -d ./$PACK'                                       >> $BUILD && \
  echo 'CC=i686-w64-mingw32-gcc GOOS=windows GOARCH=386 CGO_ENABLED=1 go build $V -o $NAME-windows-386.exe ./$PACK'            >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Compiling for darwin/amd64...'                                                                                    >> $BUILD && \
  echo 'CC=o64-clang HOST=x86_64-apple-darwin10 PREFIX=/usr/local $BUILD_DEPS'                                                 >> $BUILD && \
  echo 'CC=o64-clang GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go get -d ./$PACK'                                                 >> $BUILD && \
  echo 'CC=o64-clang GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build $V $R -o $NAME-darwin-amd64$R ./$PACK'                    >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Compiling for darwin/386...'                                                                                      >> $BUILD && \
  echo 'CC=o32-clang HOST=i386-apple-darwin10 PREFIX=/usr/local $BUILD_DEPS'                                                   >> $BUILD && \
  echo 'CC=o32-clang GOOS=darwin GOARCH=386 CGO_ENABLED=1 go get -d ./$PACK'                                                   >> $BUILD && \
  echo 'CC=o32-clang GOOS=darwin GOARCH=386 CGO_ENABLED=1 go build $V -o $NAME-darwin-386 ./$PACK'                             >> $BUILD && \
  echo                                                                                                                         >> $BUILD && \
  echo 'echo Moving binaries to host...'                                                                                       >> $BUILD && \
  echo 'cp `ls -t | head -n 7` /build'                                                                                         >> $BUILD && \
  chmod +x $BUILD

ENTRYPOINT ["./build.sh"]
