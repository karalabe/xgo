#!/bin/bash
#
# Contains the main cross compiler, that individually sets up each target build
# platform, compiles all the C dependencies, then build the requested executable
# itself.
#
# Usage: build.sh <import path>
#
# Needed environment variables:
#   REPO_REMOTE - Optional VCS remote if not the primary repository is needed
#   REPO_BRANCH - Optional VCS branch to use, if not the master branch
#   DEPS        - Optional list of C dependency packages to build
#   PACK        - Optional sub-package, if not the import path is being built
#   OUT         - Optional output prefix to override the package name
#   FLAG_V      - Optional verbosity flag to set on the Go builder
#   FLAG_X      - Optional flag to print the build progress commands
#   FLAG_RACE   - Optional race flag to set on the Go builder
#   TARGETS     - Comma separated list of build targets to compile for
#   GO_VERSION  - Bootstrapped version of Go to disable uncupported targets

# Download the canonical import path (may fail, don't allow failures beyond)
echo "Fetching main repository $1..."
go get -d $1
set -e

cd $GOPATH/src/$1
export GOPATH=$GOPATH:`pwd`/Godeps/_workspace

# Switch over the code-base to another checkout if requested
if [ "$REPO_REMOTE" != "" ]; then
  echo "Switching over to remote $REPO_REMOTE..."
  if [ -d ".git" ]; then
    git remote set-url origin $REPO_REMOTE
    git pull
  elif [ -d ".hg" ]; then
    echo -e "[paths]\ndefault = $REPO_REMOTE\n" >> .hg/hgrc
    hg pull
  fi
fi

if [ "$REPO_BRANCH" != "" ]; then
  echo "Switching over to branch $REPO_BRANCH..."
  if [ -d ".git" ]; then
    git checkout $REPO_BRANCH
  elif [ -d ".hg" ]; then
    hg checkout $REPO_BRANCH
  fi
fi

# Download all the C dependencies
echo "Fetching dependencies..."
mkdir /deps
DEPS=($DEPS) && for dep in "${DEPS[@]}"; do
  echo Downloading $dep
  if [ "${dep##*.}" == "tar" ]; then wget -q $dep -O - | tar -C /deps -x; fi
  if [ "${dep##*.}" == "gz" ]; then wget -q $dep -O - | tar -C /deps -xz; fi
  if [ "${dep##*.}" == "bz2" ]; then wget -q $dep -O - | tar -C /deps -xj; fi
done

# Configure some global build parameters
NAME=`basename $1/$PACK`
if [ "$OUT" != "" ]; then
  NAME=$OUT
fi

if [ "$FLAG_V" == "true" ]; then V=-v; fi
if [ "$FLAG_X" == "true" ]; then X=-x; fi
if [ "$FLAG_RACE" == "true" ]; then R=-race; fi

# If no build targets were specified, inject a catch all wildcard
if [ "$TARGETS" == "" ]; then
  TARGETS="./."
fi

# Build for each requested platform individually
builds=0
for TARGET in $TARGETS; do
  # Split the target into platform and architecture
  XGOOS=`echo $TARGET | cut -d '/' -f 1`
  XGOARCH=`echo $TARGET | cut -d '/' -f 2`

  # Check and build for Android targets
  if ([ $XGOOS == "." ] || [[ $XGOOS == android* ]]); then
    # Split the platform version and configure the linker options
    PLATFORM=`echo $XGOOS | cut -d '-' -f 2`
    if [ $XGOOS == "." ] || [ "$PLATFORM" == "" ] || [ "$PLATFORM" == "." ]; then
      PLATFORM=$ANDROID_PLATFORM
    fi
    if [ "$PLATFORM" -ge 16 ]; then
      CGO_CCPIE="-fPIE"
      CGO_LDPIE="-fPIE"
      EXT_LDPIE="-extldflags=-pie"
    fi
    # Iterate over the requested architectures, bootstrap and
    if [ $XGOARCH == "." ] || [ $XGOARCH == "arm" ]; then
      if [ "$GO_VERSION" -lt 150 ]; then
        echo "Go version too low, skipping android-$PLATFORM/arm..."
      else
        echo "Assembling toolchain for android-$PLATFORM/arm..."
        $ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --ndk-dir=$ANDROID_NDK_ROOT --install-dir=/usr/$ANDROID_CHAIN_ARM --toolchain=$ANDROID_CHAIN_ARM --arch=arm --system=linux-x86_64

        echo "Bootstrapping android-$PLATFORM/arm..."
        CC=arm-linux-androideabi-gcc GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/arm..."
        CC=arm-linux-androideabi-gcc CXX=arm-linux-androideabi-g++ HOST=arm-linux-androideabi PREFIX=/usr/$ANDROID_CHAIN_ARM $BUILD_DEPS /deps
        CC=arm-linux-androideabi-gcc CXX=arm-linux-androideabi-g++ GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_CXXFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go get $V $X -d ./$PACK
        CC=arm-linux-androideabi-gcc CXX=arm-linux-androideabi-g++ GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_CXXFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go build --ldflags="$EXT_LDPIE" $V $X $R -o $NAME-android-$PLATFORM-arm$R ./$PACK
        builds=$((builds+1))
      fi
    fi
  fi
  # Check and build for Linux targets
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]); then
    echo "Compiling for linux/amd64..."
    HOST=x86_64-linux PREFIX=/usr/local $BUILD_DEPS /deps
    GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go get $V $X -d ./$PACK
    GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build $V $X $R -o $NAME-linux-amd64$R ./$PACK
    builds=$((builds+1))
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "386" ]); then
    echo "Compiling for linux/386..."
    HOST=i686-linux PREFIX=/usr/local $BUILD_DEPS /deps
    GOOS=linux GOARCH=386 CGO_ENABLED=1 go get $V $X -d ./$PACK
    GOOS=linux GOARCH=386 CGO_ENABLED=1 go build $V $X -o $NAME-linux-386 ./$PACK
    builds=$((builds+1))
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "arm" ]); then
    echo "Compiling for linux/arm..."
    CC=arm-linux-gnueabi-gcc CXX=arm-linux-gnueabi-g++ HOST=arm-linux PREFIX=/usr/local/arm $BUILD_DEPS /deps
    CC=arm-linux-gnueabi-gcc CXX=arm-linux-gnueabi-g++ GOOS=linux GOARCH=arm CGO_ENABLED=1 GOARM=5 go get $V $X -d ./$PACK
    CC=arm-linux-gnueabi-gcc CXX=arm-linux-gnueabi-g++ GOOS=linux GOARCH=arm CGO_ENABLED=1 GOARM=5 go build $V $X -o $NAME-linux-arm ./$PACK
    builds=$((builds+1))
  fi
  # Check and build for Windows targets
  if ([ $XGOOS == "." ] || [ $XGOOS == "windows" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]); then
    echo "Compiling for windows/amd64..."
    CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ HOST=x86_64-w64-mingw32 PREFIX=/usr/x86_64-w64-mingw32 $BUILD_DEPS /deps
    CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go get $V $X -d ./$PACK
    CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go build $V $X $R -o $NAME-windows-amd64$R.exe ./$PACK
    builds=$((builds+1))
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "windows" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "386" ]); then
    echo "Compiling for windows/386..."
    CC=i686-w64-mingw32-gcc CXX=i686-w64-mingw32-g++ HOST=i686-w64-mingw32 PREFIX=/usr/i686-w64-mingw32 $BUILD_DEPS /deps
    CC=i686-w64-mingw32-gcc CXX=i686-w64-mingw32-g++ GOOS=windows GOARCH=386 CGO_ENABLED=1 go get $V $X -d ./$PACK
    CC=i686-w64-mingw32-gcc CXX=i686-w64-mingw32-g++ GOOS=windows GOARCH=386 CGO_ENABLED=1 go build $V $X -o $NAME-windows-386.exe ./$PACK
    builds=$((builds+1))
  fi
  # Check and build for OSX targets
  if ([ $XGOOS == "." ] || [ $XGOOS == "darwin" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]); then
    echo "Compiling for darwin/amd64..."
    CC=o64-clang CXX=o64-clang++ HOST=x86_64-apple-darwin10 PREFIX=/usr/local $BUILD_DEPS /deps
    CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go get $V $X -d ./$PACK
    CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build -ldflags=-s $V $X $R -o $NAME-darwin-amd64$R ./$PACK
    builds=$((builds+1))
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "darwin" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "386" ]); then
    echo "Compiling for darwin/386..."
    CC=o32-clang CXX=o32-clang++ HOST=i386-apple-darwin10 PREFIX=/usr/local $BUILD_DEPS /deps
    CC=o32-clang CXX=o32-clang++ GOOS=darwin GOARCH=386 CGO_ENABLED=1 go get $V $X -d ./$PACK
    CC=o32-clang CXX=o32-clang++ GOOS=darwin GOARCH=386 CGO_ENABLED=1 go build -ldflags=-s $V $X -o $NAME-darwin-386 ./$PACK
    builds=$((builds+1))
  fi
done

if [ "$builds" -eq 0 ]; then
  echo "No build targets matched!"
else
  echo "Moving $builds binaries to host..."
  cp `ls -t | head -n $builds` /build
fi
