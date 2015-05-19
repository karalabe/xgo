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
#   FLAG_RACE   - Optional race flag to set on the Go builder

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
if [ "$FLAG_RACE" == "true" ]; then R=-race; fi

# Build for each platform individually
echo "Compiling for linux/amd64..."
HOST=x86_64-linux PREFIX=/usr/local $BUILD_DEPS /deps
GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go get -d ./$PACK
GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build $V $R -o $NAME-linux-amd64$R ./$PACK

echo "Compiling for linux/386..."
CXX=g++ CXXFLAGS=-m32 HOST=i686-linux PREFIX=/usr/local $BUILD_DEPS /deps
CXX=g++ CXXFLAGS=-m32 GOOS=linux GOARCH=386 CGO_ENABLED=1 go get -d ./$PACK
CXX=g++ CXXFLAGS=-m32 GOOS=linux GOARCH=386 CGO_ENABLED=1 go build $V -o $NAME-linux-386 ./$PACK

echo "Compiling for linux/arm..."
CC=arm-linux-gnueabi-gcc HOST=arm-linux PREFIX=/usr/local/arm $BUILD_DEPS /deps
CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm CGO_ENABLED=1 GOARM=5 go get -d ./$PACK
CC=arm-linux-gnueabi-gcc GOOS=linux GOARCH=arm CGO_ENABLED=1 GOARM=5 go build $V -o $NAME-linux-arm ./$PACK

echo "Compiling for windows/amd64..."
CXX=x86_64-w64-mingw32-g++ CC=x86_64-w64-mingw32-gcc HOST=x86_64-w64-mingw32 PREFIX=/usr/x86_64-w64-mingw32 $BUILD_DEPS /deps
CXX=x86_64-w64-mingw32-g++ CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go get -d ./$PACK
CXX=x86_64-w64-mingw32-g++ CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 CGO_ENABLED=1 go build $V $R -o $NAME-windows-amd64$R.exe ./$PACK

echo "Compiling for windows/386..."
CXX=i686-w64-mingw32-g++ CC=i686-w64-mingw32-gcc HOST=i686-w64-mingw32 PREFIX=/usr/i686-w64-mingw32 $BUILD_DEPS /deps
CXX=i686-w64-mingw32-g++ CC=i686-w64-mingw32-gcc GOOS=windows GOARCH=386 CGO_ENABLED=1 go get -d ./$PACK
CXX=i686-w64-mingw32-g++ CC=i686-w64-mingw32-gcc GOOS=windows GOARCH=386 CGO_ENABLED=1 go build $V -o $NAME-windows-386.exe ./$PACK

echo "Compiling for darwin/amd64..."
CXX=o32-clang++ CC=o64-clang HOST=x86_64-apple-darwin10 PREFIX=/usr/local $BUILD_DEPS /deps
CXX=o32-clang++ CC=o64-clang GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go get -d ./$PACK
CXX=o32-clang++ CC=o64-clang GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build $V $R -o $NAME-darwin-amd64$R ./$PACK

echo "Compiling for darwin/386..."
CXX=o32-clang++ CC=o32-clang HOST=i386-apple-darwin10 PREFIX=/usr/local $BUILD_DEPS /deps
CXX=o32-clang++ CC=o32-clang GOOS=darwin GOARCH=386 CGO_ENABLED=1 go get -d ./$PACK
CXX=o32-clang++ CC=o32-clang GOOS=darwin GOARCH=386 CGO_ENABLED=1 go build $V -o $NAME-darwin-386 ./$PACK

echo "Moving binaries to host..."
cp `ls -t | head -n 7` /build
