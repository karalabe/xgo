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

if [ -n $BEFORE_BUILD ]; then
	chmod +x /scripts/$BEFORE_BUILD
	echo "Execute /scripts/$BEFORE_BUILD"
	/scripts/$BEFORE_BUILD
fi

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
        export ANDROID_SYSROOT=$ANDROID_PLATROOT/android-$PLATFORM/arch-arm

        echo "Bootstrapping android-$PLATFORM/arm..."
        CC=arm-linux-androideabi-gcc GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/arm..."
        CC="arm-linux-androideabi-gcc --sysroot=$ANDROID_SYSROOT" HOST=arm-linux-androideabi PREFIX=$ANDROID_SYSROOT/usr $BUILD_DEPS /deps
        CC=arm-linux-androideabi-gcc GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go get $V $X -d ./$PACK
        CC=arm-linux-androideabi-gcc GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go build --ldflags="$EXT_LDPIE" $V $X $R -o $NAME-android-$PLATFORM-arm$R ./$PACK
        builds=$((builds+1))
      fi
    fi
    if ([ $XGOARCH == "." ] || [ $XGOARCH == "386" ]) && [ "$PLATFORM" -ge 9 ]; then
      if [ "$GO_VERSION" -lt 160 ]; then
        echo "Go version too low, skipping android-$PLATFORM/386..."
      else
        export ANDROID_SYSROOT=$ANDROID_PLATROOT/android-$PLATFORM/arch-x86

        echo "Bootstrapping android-$PLATFORM/386..."
        CC=i686-linux-android-gcc GOOS=android GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/386..."
        CC="i686-linux-android-gcc --sysroot=$ANDROID_SYSROOT" HOST=i686-linux-android PREFIX=$ANDROID_SYSROOT/usr $BUILD_DEPS /deps
        CC=i686-linux-android-gcc GOOS=android GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go get $V $X -d ./$PACK
        CC=i686-linux-android-gcc GOOS=android GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go build --ldflags="$EXT_LDPIE" $V $X $R -o $NAME-android-$PLATFORM-386$R ./$PACK
        builds=$((builds+1))
      fi
    fi
    if ([ $XGOARCH == "." ] || [ $XGOARCH == "mips" ]) && [ "$PLATFORM" -ge 9 ]; then
      if [ "$GO_VERSION" -lt 160 ]; then
        echo "Go version too low, skipping android-$PLATFORM/mips..."
      else
        export ANDROID_SYSROOT=$ANDROID_PLATROOT/android-$PLATFORM/arch-mips

        echo "Bootstrapping android-$PLATFORM/mips..."
        CC==mipsel-linux-android-gcc GOOS=android GOARCH=mips CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/mips..."
        CC="mipsel-linux-android-gcc --sysroot=$ANDROID_SYSROOT" HOST=mipsel-linux-android PREFIX=$ANDROID_SYSROOT/usr $BUILD_DEPS /deps
        CC=mipsel-linux-android-gcc GOOS=android GOARCH=mips CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go get $V $X -d ./$PACK
        CC=mipsel-linux-android-gcc GOOS=android GOARCH=mips CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go build --ldflags="$EXT_LDPIE" $V $X $R -o $NAME-android-$PLATFORM-mips$R ./$PACK
        builds=$((builds+1))
      fi
    fi
    if ([ $XGOARCH == "." ] || [ $XGOARCH == "arm64" ]) && [ "$PLATFORM" -ge 21 ]; then
      if [ "$GO_VERSION" -lt 160 ]; then
        echo "Go version too low, skipping android-$PLATFORM/arm64..."
      else
        export ANDROID_SYSROOT=$ANDROID_PLATROOT/android-$PLATFORM/arch-arm64

        echo "Bootstrapping android-$PLATFORM/arm64..."
        CC===aarch64-linux-android-gcc GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/arm64..."
        CC="aarch64-linux-android-gcc --sysroot=$ANDROID_SYSROOT" HOST=aarch64-linux-android PREFIX=$ANDROID_SYSROOT/usr $BUILD_DEPS /deps
        CC=aarch64-linux-android-gcc GOOS=android GOARCH=arm64 GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go get $V $X -d ./$PACK
        CC=aarch64-linux-android-gcc GOOS=android GOARCH=arm64 GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go build --ldflags="$EXT_LDPIE" $V $X $R -o $NAME-android-$PLATFORM-arm64$R ./$PACK
        builds=$((builds+1))
      fi
    fi
    if ([ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]) && [ "$PLATFORM" -ge 21 ]; then
      if [ "$GO_VERSION" -lt 160 ]; then
        echo "Go version too low, skipping android-$PLATFORM/amd64..."
      else
        export ANDROID_SYSROOT=$ANDROID_PLATROOT/android-$PLATFORM/arch-x86_64

        echo "Bootstrapping android-$PLATFORM/amd64..."
        CC=x86_64-linux-android-gcc GOOS=android GOARCH=amd64 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/amd64..."
        CC="x86_64-linux-android-gcc --sysroot=$ANDROID_SYSROOT" HOST=x86_64-linux-android PREFIX=$ANDROID_SYSROOT/usr $BUILD_DEPS /deps
        CC=x86_64-linux-android-gcc GOOS=android GOARCH=amd64 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go get $V $X -d ./$PACK
        CC=x86_64-linux-android-gcc GOOS=android GOARCH=amd64 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go build --ldflags="$EXT_LDPIE" $V $X $R -o $NAME-android-$PLATFORM-amd64$R ./$PACK
        builds=$((builds+1))
      fi
    fi
    if ([ $XGOARCH == "." ] || [ $XGOARCH == "mips64" ]) && [ "$PLATFORM" -ge 21 ]; then
      if [ "$GO_VERSION" -lt 160 ]; then
        echo "Go version too low, skipping android-$PLATFORM/mips64..."
      else
        export ANDROID_SYSROOT=$ANDROID_PLATROOT/android-$PLATFORM/arch-mips64

        echo "Bootstrapping android-$PLATFORM/mips64..."
        CC=mips64el-linux-android-gcc GOOS=android GOARCH=mips64 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/mips64..."
        CC="mips64el-linux-android-gcc --sysroot=$ANDROID_SYSROOT" HOST=mips64el-linux-android PREFIX=$ANDROID_SYSROOT/usr $BUILD_DEPS /deps
        CC=mips64el-linux-android-gcc GOOS=android GOARCH=mips64 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go get $V $X -d ./$PACK
        CC=mips64el-linux-android-gcc GOOS=android GOARCH=mips64 CGO_ENABLED=1 CGO_CFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_CCPIE" CGO_LDFLAGS="--sysroot=$ANDROID_SYSROOT $CGO_LDPIE" go build --ldflags="$EXT_LDPIE" $V $X $R -o $NAME-android-$PLATFORM-mips64$R ./$PACK
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
    CC=arm-linux-gnueabi-gcc HOST=arm-linux PREFIX=/usr/local/arm $BUILD_DEPS /deps
    CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm CGO_ENABLED=1 GOARM=5 go get $V $X -d ./$PACK
    CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm CGO_ENABLED=1 GOARM=5 go build $V $X -o $NAME-linux-arm ./$PACK
    builds=$((builds+1))
  fi
  # Check and build for Windows targets
  if ([ $XGOOS == "." ] || [ $XGOOS == "windows" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]); then
    echo "Compiling for windows/amd64..."
    CC=x86_64-w64-mingw32-gcc HOST=x86_64-w64-mingw32 PREFIX=/usr/x86_64-w64-mingw32 $BUILD_DEPS /deps
    CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go get $V $X -d ./$PACK
    CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go build $V $X $R -o $NAME-windows-amd64$R.exe ./$PACK
    builds=$((builds+1))
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "windows" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "386" ]); then
    echo "Compiling for windows/386..."
    CC=i686-w64-mingw32-gcc HOST=i686-w64-mingw32 PREFIX=/usr/i686-w64-mingw32 $BUILD_DEPS /deps
    CC=i686-w64-mingw32-gcc GOOS=windows GOARCH=386 CGO_ENABLED=1 go get $V $X -d ./$PACK
    CC=i686-w64-mingw32-gcc GOOS=windows GOARCH=386 CGO_ENABLED=1 go build $V $X -o $NAME-windows-386.exe ./$PACK
    builds=$((builds+1))
  fi
  # Check and build for OSX targets
  if ([ $XGOOS == "." ] || [ $XGOOS == "darwin" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]); then
    echo "Compiling for darwin/amd64..."
    CC=o64-clang HOST=x86_64-apple-darwin10 PREFIX=/usr/local $BUILD_DEPS /deps
    CC=o64-clang GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go get $V $X -d ./$PACK
    CC=o64-clang GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build -ldflags=-s $V $X $R -o $NAME-darwin-amd64$R ./$PACK
    builds=$((builds+1))
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "darwin" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "386" ]); then
    echo "Compiling for darwin/386..."
    CC=o32-clang HOST=i386-apple-darwin10 PREFIX=/usr/local $BUILD_DEPS /deps
    CC=o32-clang GOOS=darwin GOARCH=386 CGO_ENABLED=1 go get $V $X -d ./$PACK
    CC=o32-clang GOOS=darwin GOARCH=386 CGO_ENABLED=1 go build -ldflags=-s $V $X -o $NAME-darwin-386 ./$PACK
    builds=$((builds+1))
  fi
done

if [ "$builds" -eq 0 ]; then
  echo "No build targets matched!"
else
  echo "Moving $builds binaries to host..."
  cp `ls -t | head -n $builds` /build
fi
