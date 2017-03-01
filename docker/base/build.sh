#!/bin/bash
#
# Contains the main cross compiler, that individually sets up each target build
# platform, compiles all the C dependencies, then build the requested executable
# itself.
#
# Usage: build.sh <import path>
#
# Needed environment variables:
#   REPO_REMOTE    - Optional VCS remote if not the primary repository is needed
#   REPO_BRANCH    - Optional VCS branch to use, if not the master branch
#   DEPS           - Optional list of C dependency packages to build
#   ARGS           - Optional arguments to pass to C dependency configure scripts
#   PACK           - Optional sub-package, if not the import path is being built
#   OUT            - Optional output prefix to override the package name
#   FLAG_V         - Optional verbosity flag to set on the Go builder
#   FLAG_X         - Optional flag to print the build progress commands
#   FLAG_RACE      - Optional race flag to set on the Go builder
#   FLAG_TAGS      - Optional tag flag to set on the Go builder
#   FLAG_LDFLAGS   - Optional ldflags flag to set on the Go builder
#   FLAG_BUILDMODE - Optional buildmode flag to set on the Go builder
#   TARGETS        - Comma separated list of build targets to compile for
#   GO_VERSION     - Bootstrapped version of Go to disable uncupported targets
#   EXT_GOPATH     - GOPATH elements mounted from the host filesystem

# Define a function that figures out the binary extension
function extension {
  if [ "$FLAG_BUILDMODE" == "archive" ] || [ "$FLAG_BUILDMODE" == "c-archive" ]; then
    if [ "$1" == "windows" ]; then
      echo ".lib"
    else
      echo ".a"
    fi
  elif [ "$FLAG_BUILDMODE" == "shared" ] || [ "$FLAG_BUILDMODE" == "c-shared" ]; then
    if [ "$1" == "windows" ]; then
      echo ".dll"
    elif [ "$1" == "darwin" ] || [ "$1" == "ios" ]; then
      echo ".dylib"
    else
      echo ".so"
    fi
  else
    if [ "$1" == "windows" ]; then
      echo ".exe"
    fi
  fi
}

# Either set a local build environemnt, or pull any remote imports
if [ "$EXT_GOPATH" != "" ]; then
  # If local builds are requested, inject the sources
  echo "Building locally $1..."
  export GOPATH=$GOPATH:$EXT_GOPATH
  set -e

  # Find and change into the package folder
  cd `go list -e -f {{.Dir}} $1`
  export GOPATH=$GOPATH:`pwd`/Godeps/_workspace
else
  # Inject all possible Godep paths to short circuit go gets
  GOPATH_ROOT=$GOPATH/src
  IMPORT_PATH=$1
  while [ "$IMPORT_PATH" != "." ]; do
    export GOPATH=$GOPATH:$GOPATH_ROOT/$IMPORT_PATH/Godeps/_workspace
    IMPORT_PATH=`dirname $IMPORT_PATH`
  done

  # Otherwise download the canonical import path (may fail, don't allow failures beyond)
  echo "Fetching main repository $1..."
  go get -v -d $1
  set -e

  cd $GOPATH_ROOT/$1

  # Switch over the code-base to another checkout if requested
  if [ "$REPO_REMOTE" != "" ] || [ "$REPO_BRANCH" != "" ]; then
    # Detect the version control system type
    IMPORT_PATH=$1
    while [ "$IMPORT_PATH" != "." ] && [ "$REPO_TYPE" == "" ]; do
      if [ -d "$GOPATH_ROOT/$IMPORT_PATH/.git" ]; then
        REPO_TYPE="git"
      elif  [ -d "$GOPATH_ROOT/$IMPORT_PATH/.hg" ]; then
        REPO_TYPE="hg"
      fi
      IMPORT_PATH=`dirname $IMPORT_PATH`
    done

    if [ "$REPO_TYPE" == "" ]; then
      echo "Unknown version control system type, cannot switch remotes and branches."
      exit -1
    fi
    # If we have a valid VCS, execute the switch operations
    if [ "$REPO_REMOTE" != "" ]; then
      echo "Switching over to remote $REPO_REMOTE..."
      if [ "$REPO_TYPE" == "git" ]; then
        git remote set-url origin $REPO_REMOTE
        git fetch --all
        git reset --hard origin/HEAD
        git clean -dxf
      elif [ "$REPO_TYPE" == "hg" ]; then
        echo -e "[paths]\ndefault = $REPO_REMOTE\n" >> .hg/hgrc
        hg pull
      fi
    fi
    if [ "$REPO_BRANCH" != "" ]; then
      echo "Switching over to branch $REPO_BRANCH..."
      if [ "$REPO_TYPE" == "git" ]; then
        git reset --hard origin/$REPO_BRANCH
        git clean -dxf
      elif [ "$REPO_TYPE" == "hg" ]; then
        hg checkout $REPO_BRANCH
      fi
    fi
  fi
fi

# Download all the C dependencies
mkdir /deps
DEPS=($DEPS) && for dep in "${DEPS[@]}"; do
  if [ "${dep##*.}" == "tar" ]; then cat "/deps-cache/`basename $dep`" | tar -C /deps -x; fi
  if [ "${dep##*.}" == "gz" ];  then cat "/deps-cache/`basename $dep`" | tar -C /deps -xz; fi
  if [ "${dep##*.}" == "bz2" ]; then cat "/deps-cache/`basename $dep`" | tar -C /deps -xj; fi
done

DEPS_ARGS=($ARGS)

# Save the contents of the pre-build /usr/local folder for post cleanup
USR_LOCAL_CONTENTS=`ls /usr/local`

# Configure some global build parameters
NAME=`basename $1/$PACK`
if [ "$OUT" != "" ]; then
  NAME=$OUT
fi

if [ "$FLAG_V" == "true" ];    then V=-v; fi
if [ "$FLAG_X" == "true" ];    then X=-x; fi
if [ "$FLAG_RACE" == "true" ]; then R=-race; fi
if [ "$FLAG_TAGS" != "" ];     then T=(--tags "$FLAG_TAGS"); fi
if [ "$FLAG_LDFLAGS" != "" ];  then LD="$FLAG_LDFLAGS"; fi

if [ "$FLAG_BUILDMODE" != "" ] && [ "$FLAG_BUILDMODE" != "default" ]; then BM="--buildmode=$FLAG_BUILDMODE"; fi

# If no build targets were specified, inject a catch all wildcard
if [ "$TARGETS" == "" ]; then
  TARGETS="./."
fi

# Build for each requested platform individually
for TARGET in $TARGETS; do
  # Split the target into platform and architecture
  XGOOS=`echo $TARGET | cut -d '/' -f 1`
  XGOARCH=`echo $TARGET | cut -d '/' -f 2`

  # Check and build for Android targets
  if ([ $XGOOS == "." ] || [[ $XGOOS == android* ]]); then
    # Split the platform version and configure the linker options
    PLATFORM=`echo $XGOOS | cut -d '-' -f 2`
    if [ "$PLATFORM" == "" ] || [ "$PLATFORM" == "." ] || [ "$PLATFORM" == "android" ]; then
      PLATFORM=16 # Jelly Bean 4.0.0
    fi
    if [ "$PLATFORM" -ge 16 ]; then
      CGO_CCPIE="-fPIE"
      CGO_LDPIE="-fPIE"
      EXT_LDPIE="-extldflags=-pie"
    else
      unset CGO_CCPIE CGO_LDPIE EXT_LDPIE
    fi
    mkdir -p /build-android-aar

    # Iterate over the requested architectures, bootstrap and build
    if [ $XGOARCH == "." ] || [ $XGOARCH == "arm" ] || [ $XGOARCH == "aar" ]; then
      if [ "$GO_VERSION" -lt 150 ]; then
        echo "Go version too low, skipping android-$PLATFORM/arm..."
      else
        # Include a linker workaround for pre Go 1.6 releases
        if [ "$GO_VERSION" -lt 160 ]; then
          EXT_LDAMD="-extldflags=-Wl,--allow-multiple-definition"
        fi

        echo "Assembling toolchain for android-$PLATFORM/arm..."
        $ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --ndk-dir=$ANDROID_NDK_ROOT --install-dir=/usr/$ANDROID_CHAIN_ARM --toolchain=$ANDROID_CHAIN_ARM --arch=arm > /dev/null 2>&1

        echo "Bootstrapping android-$PLATFORM/arm..."
        CC=arm-linux-androideabi-gcc GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/arm..."
        CC=arm-linux-androideabi-gcc CXX=arm-linux-androideabi-g++ HOST=arm-linux-androideabi PREFIX=/usr/$ANDROID_CHAIN_ARM/arm-linux-androideabi $BUILD_DEPS /deps ${DEPS_ARGS[@]}
        export PKG_CONFIG_PATH=/usr/$ANDROID_CHAIN_ARM/arm-linux-androideabi/lib/pkgconfig

        if [ $XGOARCH == "." ] || [ $XGOARCH == "arm" ]; then
          CC=arm-linux-androideabi-gcc CXX=arm-linux-androideabi-g++ GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_CXXFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
          CC=arm-linux-androideabi-gcc CXX=arm-linux-androideabi-g++ GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_CXXFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go build $V $X "${T[@]}" --ldflags="$V $EXT_LDPIE $EXT_LDAMD $LD" $BM -o "/build/$NAME-android-$PLATFORM-arm`extension android`" ./$PACK
        fi
        if [ $XGOARCH == "." ] || [ $XGOARCH == "aar" ]; then
          CC=arm-linux-androideabi-gcc CXX=arm-linux-androideabi-g++ GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
          CC=arm-linux-androideabi-gcc CXX=arm-linux-androideabi-g++ GOOS=android GOARCH=arm GOARM=7 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $EXT_LDAMD $LD" --buildmode=c-shared -o "/build-android-aar/$NAME-android-$PLATFORM-arm.so" ./$PACK
        fi
      fi
    fi
    if [ "$GO_VERSION" -lt 160 ]; then
      echo "Go version too low, skipping android-$PLATFORM/386,arm64..."
    else
      if [ "$PLATFORM" -ge 9 ] && ([ $XGOARCH == "." ] || [ $XGOARCH == "386" ] || [ $XGOARCH == "aar" ]); then
        echo "Assembling toolchain for android-$PLATFORM/386..."
        $ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --ndk-dir=$ANDROID_NDK_ROOT --install-dir=/usr/$ANDROID_CHAIN_386 --toolchain=$ANDROID_CHAIN_386 --arch=x86 > /dev/null 2>&1

        echo "Bootstrapping android-$PLATFORM/386..."
        CC=i686-linux-android-gcc GOOS=android GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/386..."
        CC=i686-linux-android-gcc CXX=i686-linux-android-g++ HOST=i686-linux-android PREFIX=/usr/$ANDROID_CHAIN_386/i686-linux-android $BUILD_DEPS /deps ${DEPS_ARGS[@]}
        export PKG_CONFIG_PATH=/usr/$ANDROID_CHAIN_386/i686-linux-android/lib/pkgconfig

        if [ $XGOARCH == "." ] || [ $XGOARCH == "386" ]; then
          CC=i686-linux-android-gcc CXX=i686-linux-android-g++ GOOS=android GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_CXXFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
          CC=i686-linux-android-gcc CXX=i686-linux-android-g++ GOOS=android GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_CXXFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go build $V $X "${T[@]}" --ldflags="$V $EXT_LDPIE $LD" $BM -o "/build/$NAME-android-$PLATFORM-386`extension android`" ./$PACK
        fi
        if [ $XGOARCH == "." ] || [ $XGOARCH == "aar" ]; then
          CC=i686-linux-android-gcc CXX=i686-linux-android-g++ GOOS=android GOARCH=386 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
          CC=i686-linux-android-gcc CXX=i686-linux-android-g++ GOOS=android GOARCH=386 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" --buildmode=c-shared -o "/build-android-aar/$NAME-android-$PLATFORM-386.so" ./$PACK
        fi
      fi
      if [ "$PLATFORM" -ge 21 ] && ([ $XGOARCH == "." ] || [ $XGOARCH == "arm64" ] || [ $XGOARCH == "aar" ]); then
        echo "Assembling toolchain for android-$PLATFORM/arm64..."
        $ANDROID_NDK_ROOT/build/tools/make-standalone-toolchain.sh --ndk-dir=$ANDROID_NDK_ROOT --install-dir=/usr/$ANDROID_CHAIN_ARM64 --toolchain=$ANDROID_CHAIN_ARM64 --arch=arm64 > /dev/null 2>&1

        echo "Bootstrapping android-$PLATFORM/arm64..."
        CC=aarch64-linux-android-gcc GOOS=android GOARCH=arm64 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go install std

        echo "Compiling for android-$PLATFORM/arm64..."
        CC=aarch64-linux-android-gcc CXX=aarch64-linux-android-g++ HOST=aarch64-linux-android PREFIX=/usr/$ANDROID_CHAIN_ARM64/aarch64-linux-android $BUILD_DEPS /deps ${DEPS_ARGS[@]}
        export PKG_CONFIG_PATH=/usr/$ANDROID_CHAIN_ARM64/aarch64-linux-android/lib/pkgconfig

        if [ $XGOARCH == "." ] || [ $XGOARCH == "arm64" ]; then
          CC=aarch64-linux-android-gcc CXX=aarch64-linux-android-g++ GOOS=android GOARCH=arm64 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_CXXFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
          CC=aarch64-linux-android-gcc CXX=aarch64-linux-android-g++ GOOS=android GOARCH=arm64 CGO_ENABLED=1 CGO_CFLAGS="$CGO_CCPIE" CGO_CXXFLAGS="$CGO_CCPIE" CGO_LDFLAGS="$CGO_LDPIE" go build $V $X "${T[@]}" --ldflags="$V $EXT_LDPIE $LD" $BM -o "/build/$NAME-android-$PLATFORM-arm64`extension android`" ./$PACK
        fi
        if [ $XGOARCH == "." ] || [ $XGOARCH == "aar" ]; then
          CC=aarch64-linux-android-gcc CXX=aarch64-linux-android-g++ GOOS=android GOARCH=arm64 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
          CC=aarch64-linux-android-gcc CXX=aarch64-linux-android-g++ GOOS=android GOARCH=arm64 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" --buildmode=c-shared -o "/build-android-aar/$NAME-android-$PLATFORM-arm64.so" ./$PACK
        fi
      fi
    fi
    # Assemble the Android Archive from the built shared libraries
    if [ $XGOARCH == "." ] || [ $XGOARCH == "aar" ]; then
      title=${NAME^}
      archive=/build/$NAME-android-$PLATFORM-aar
      bundle=/build/$NAME-android-$PLATFORM.aar

      # Generate the Java import path based on the Go one
      package=`go list ./$PACK | tr '-' '_'`
      package=$(for p in `echo ${package//\// }`; do echo $p | awk 'BEGIN{FS="."}{for (i=NF; i>0; i--){printf "%s.", $i;}}'; done | sed 's/.$//')
      package=${package%.*}

      # Create a fresh empty Android archive
      rm -rf $archive $bundle
      mkdir -p $archive

      echo -e "<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\" package=\"$package\">\n  <uses-sdk android:minSdkVersion=\"$PLATFORM\"/>\n</manifest>" > $archive/AndroidManifest.xml
      mkdir -p $archive/res
      touch $archive/R.txt

      # Generate the JNI wrappers automatically with SWIG
      jni=`mktemp -d`
      header=`find /build-android-aar | grep '\.h$' | head -n 1`
      if [ "$header" == "" ]; then
        echo "No API C header specified, skipping android-$PLATFORM/aar..."
      else
        cp $header $jni/$NAME.h
        sed -i -e 's|__complex|complex|g' $jni/$NAME.h
        sed -i -e 's|_Complex|complex|g' $jni/$NAME.h
        echo -e "%module $title\n%{\n#include \"$NAME.h\"\n%}\n%pragma(java) jniclasscode=%{\nstatic {\nSystem.loadLibrary(\"$NAME\");\n}\n%}\n%include \"$NAME.h\"" > $jni/$NAME.i

        mkdir -p $jni/${package//.//}
        swig -java -package $package -outdir $jni/${package//.//} $jni/$NAME.i

        # Assemble the Go static libraries and the JNI interface into shared libraries
        for lib in `find /build-android-aar | grep '\.so$'`; do
          if [[ "$lib" = *-arm.so ]];   then cc=arm-linux-androideabi-gcc; abi="armeabi-v7a"; fi
          if [[ "$lib" = *-arm64.so ]]; then cc=aarch64-linux-android-gcc; abi="arm64-v8a"; fi
          if [[ "$lib" = *-386.so ]];   then cc=i686-linux-android-gcc;    abi="x86"; fi

          mkdir -p $archive/jni/$abi
          cp ${lib%.*}.h $jni/${NAME}.h
          cp $lib $archive/jni/$abi/lib${NAME}raw.so
          (cd $archive/jni/$abi && $cc -shared -fPIC -o lib${NAME}.so -I"$ANDROID_NDK_LIBC/include" -I"$ANDROID_NDK_LIBC/libs/$abi/include" -I"$jni" lib${NAME}raw.so $jni/${NAME}_wrap.c)
        done

        # Compile the Java wrapper and assemble into a .jar file
        mkdir -p $jni/build
        javac -target 1.7 -source 1.7 -cp . -d $jni/build $jni/${package//.//}/*.java
        (cd $jni/build && jar cvf $archive/classes.jar *)

        # Finally assemble the archive contents into an .aar and clean up
        (cd $archive && zip -r $bundle *)
        rm -rf $jni $archive
      fi
    fi
    # Clean up the android builds, toolchains and runtimes
    rm -rf /build-android-aar
    rm -rf /usr/local/go/pkg/android_*
    rm -rf /usr/$ANDROID_CHAIN_ARM /usr/$ANDROID_CHAIN_ARM64 /usr/$ANDROID_CHAIN_386
  fi
  # Check and build for Linux targets
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]); then
    echo "Compiling for linux/amd64..."
    HOST=x86_64-linux PREFIX=/usr/local $BUILD_DEPS /deps ${DEPS_ARGS[@]}
    GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
    GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" $R $BM -o "/build/$NAME-linux-amd64$R`extension linux`" ./$PACK
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "386" ]); then
    echo "Compiling for linux/386..."
    HOST=i686-linux PREFIX=/usr/local $BUILD_DEPS /deps ${DEPS_ARGS[@]}
    GOOS=linux GOARCH=386 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
    GOOS=linux GOARCH=386 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-386`extension linux`" ./$PACK
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "arm" ] || [ $XGOARCH == "arm-5" ]); then
    if [ "$GO_VERSION" -ge 150 ]; then
      echo "Bootstrapping linux/arm-5..."
      CC=arm-linux-gnueabi-gcc-5 GOOS=linux GOARCH=arm GOARM=5 CGO_ENABLED=1 CGO_CFLAGS="-march=armv5" CGO_CXXFLAGS="-march=armv5" go install std
    fi
    echo "Compiling for linux/arm-5..."
    CC=arm-linux-gnueabi-gcc-5 CXX=arm-linux-gnueabi-g++-5 HOST=arm-linux-gnueabi PREFIX=/usr/arm-linux-gnueabi CFLAGS="-march=armv5" CXXFLAGS="-march=armv5" $BUILD_DEPS /deps ${DEPS_ARGS[@]}
    export PKG_CONFIG_PATH=/usr/arm-linux-gnueabi/lib/pkgconfig

    CC=arm-linux-gnueabi-gcc-5 CXX=arm-linux-gnueabi-g++-5 GOOS=linux GOARCH=arm GOARM=5 CGO_ENABLED=1 CGO_CFLAGS="-march=armv5" CGO_CXXFLAGS="-march=armv5" go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
    CC=arm-linux-gnueabi-gcc-5 CXX=arm-linux-gnueabi-g++-5 GOOS=linux GOARCH=arm GOARM=5 CGO_ENABLED=1 CGO_CFLAGS="-march=armv5" CGO_CXXFLAGS="-march=armv5" go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-arm-5`extension linux`" ./$PACK
    if [ "$GO_VERSION" -ge 150 ]; then
      echo "Cleaning up Go runtime for linux/arm-5..."
      rm -rf /usr/local/go/pkg/linux_arm
    fi
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "arm-6" ]); then
    if [ "$GO_VERSION" -lt 150 ]; then
      echo "Go version too low, skipping linux/arm-6..."
    else
      echo "Bootstrapping linux/arm-6..."
      CC=arm-linux-gnueabi-gcc-5 GOOS=linux GOARCH=arm GOARM=6 CGO_ENABLED=1 CGO_CFLAGS="-march=armv6" CGO_CXXFLAGS="-march=armv6" go install std

      echo "Compiling for linux/arm-6..."
      CC=arm-linux-gnueabi-gcc-5 CXX=arm-linux-gnueabi-g++-5 HOST=arm-linux-gnueabi PREFIX=/usr/arm-linux-gnueabi CFLAGS="-march=armv6" CXXFLAGS="-march=armv6" $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/arm-linux-gnueabi/lib/pkgconfig

      CC=arm-linux-gnueabi-gcc-5 CXX=arm-linux-gnueabi-g++-5 GOOS=linux GOARCH=arm GOARM=6 CGO_ENABLED=1 CGO_CFLAGS="-march=armv6" CGO_CXXFLAGS="-march=armv6" go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=arm-linux-gnueabi-gcc-5 CXX=arm-linux-gnueabi-g++-5 GOOS=linux GOARCH=arm GOARM=6 CGO_ENABLED=1 CGO_CFLAGS="-march=armv6" CGO_CXXFLAGS="-march=armv6" go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-arm-6`extension linux`" ./$PACK

      echo "Cleaning up Go runtime for linux/arm-6..."
      rm -rf /usr/local/go/pkg/linux_arm
    fi
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "arm-7" ]); then
    if [ "$GO_VERSION" -lt 150 ]; then
      echo "Go version too low, skipping linux/arm-7..."
    else
      echo "Bootstrapping linux/arm-7..."
      CC=arm-linux-gnueabihf-gcc-5 GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="-march=armv7-a" CGO_CXXFLAGS="-march=armv7-a" go install std

      echo "Compiling for linux/arm-7..."
      CC=arm-linux-gnueabihf-gcc-5 CXX=arm-linux-gnueabihf-g++-5 HOST=arm-linux-gnueabihf PREFIX=/usr/arm-linux-gnueabihf CFLAGS="-march=armv7-a -fPIC" CXXFLAGS="-march=armv7-a -fPIC" $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/arm-linux-gnueabihf/lib/pkgconfig

      CC=arm-linux-gnueabihf-gcc-5 CXX=arm-linux-gnueabihf-g++-5 GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="-march=armv7-a -fPIC" CGO_CXXFLAGS="-march=armv7-a -fPIC" go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=arm-linux-gnueabihf-gcc-5 CXX=arm-linux-gnueabihf-g++-5 GOOS=linux GOARCH=arm GOARM=7 CGO_ENABLED=1 CGO_CFLAGS="-march=armv7-a -fPIC" CGO_CXXFLAGS="-march=armv7-a -fPIC" go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-arm-7`extension linux`" ./$PACK

      echo "Cleaning up Go runtime for linux/arm-7..."
      rm -rf /usr/local/go/pkg/linux_arm
    fi
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "arm64" ]); then
    if [ "$GO_VERSION" -lt 150 ]; then
      echo "Go version too low, skipping linux/arm64..."
    else
      echo "Compiling for linux/arm64..."
      CC=aarch64-linux-gnu-gcc-5 CXX=aarch64-linux-gnu-g++-5 HOST=aarch64-linux-gnu PREFIX=/usr/aarch64-linux-gnu $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/aarch64-linux-gnu/lib/pkgconfig

      CC=aarch64-linux-gnu-gcc-5 CXX=aarch64-linux-gnu-g++-5 GOOS=linux GOARCH=arm64 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=aarch64-linux-gnu-gcc-5 CXX=aarch64-linux-gnu-g++-5 GOOS=linux GOARCH=arm64 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-arm64`extension linux`" ./$PACK
    fi
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "mips64" ]); then
    if [ "$GO_VERSION" -lt 170 ]; then
      echo "Go version too low, skipping linux/mips64..."
    else
      echo "Compiling for linux/mips64..."
      CC=mips64-linux-gnuabi64-gcc-5 CXX=mips64-linux-gnuabi64-g++-5 HOST=mips64-linux-gnuabi64 PREFIX=/usr/mips64-linux-gnuabi64 $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/mips64-linux-gnuabi64/lib/pkgconfig

      CC=mips64-linux-gnuabi64-gcc-5 CXX=mips64-linux-gnuabi64-g++-5 GOOS=linux GOARCH=mips64 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=mips64-linux-gnuabi64-gcc-5 CXX=mips64-linux-gnuabi64-g++-5 GOOS=linux GOARCH=mips64 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-mips64`extension linux`" ./$PACK
    fi
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "mips64le" ]); then
    if [ "$GO_VERSION" -lt 170 ]; then
      echo "Go version too low, skipping linux/mips64le..."
    else
      echo "Compiling for linux/mips64le..."
      CC=mips64el-linux-gnuabi64-gcc-5 CXX=mips64el-linux-gnuabi64-g++-5 HOST=mips64el-linux-gnuabi64 PREFIX=/usr/mips64el-linux-gnuabi64 $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/mips64le-linux-gnuabi64/lib/pkgconfig

      CC=mips64el-linux-gnuabi64-gcc-5 CXX=mips64el-linux-gnuabi64-g++-5 GOOS=linux GOARCH=mips64le CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=mips64el-linux-gnuabi64-gcc-5 CXX=mips64el-linux-gnuabi64-g++-5 GOOS=linux GOARCH=mips64le CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-mips64le`extension linux`" ./$PACK
    fi
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "mips" ]); then
    if [ "$GO_VERSION" -lt 180 ]; then
      echo "Go version too low, skipping linux/mips..."
    else
      echo "Compiling for linux/mips..."
      CC=mips-linux-gnu-gcc-5 CXX=mips-linux-gnu-g++-5 HOST=mips-linux-gnu PREFIX=/usr/mips-linux-gnu $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/mips-linux-gnu/lib/pkgconfig

      CC=mips-linux-gnu-gcc-5 CXX=mips-linux-gnu-g++-5 GOOS=linux GOARCH=mips CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=mips-linux-gnu-gcc-5 CXX=mips-linux-gnu-g++-5 GOOS=linux GOARCH=mips CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-mips`extension linux`" ./$PACK
    fi
  fi
  if ([ $XGOOS == "." ] || [ $XGOOS == "linux" ]) && ([ $XGOARCH == "." ] || [ $XGOARCH == "mipsle" ]); then
    if [ "$GO_VERSION" -lt 180 ]; then
      echo "Go version too low, skipping linux/mipsle..."
    else
      echo "Compiling for linux/mipsle..."
      CC=mipsel-linux-gnu-gcc-5 CXX=mipsel-linux-gnu-g++-5 HOST=mipsel-linux-gnu PREFIX=/usr/mipsel-linux-gnu $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/mipsle-linux-gnu/lib/pkgconfig

      CC=mipsel-linux-gnu-gcc-5 CXX=mipsel-linux-gnu-g++-5 GOOS=linux GOARCH=mipsle CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=mipsel-linux-gnu-gcc-5 CXX=mipsel-linux-gnu-g++-5 GOOS=linux GOARCH=mipsle CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-linux-mipsle`extension linux`" ./$PACK
    fi
  fi
  # Check and build for Windows targets
  if [ $XGOOS == "." ] || [[ $XGOOS == windows* ]]; then
    # Split the platform version and configure the Windows NT version
    PLATFORM=`echo $XGOOS | cut -d '-' -f 2`
    if [ "$PLATFORM" == "" ] || [ "$PLATFORM" == "." ] || [ "$PLATFORM" == "windows" ]; then
      PLATFORM=4.0 # Windows NT
    fi

    MAJOR=`echo $PLATFORM | cut -d '.' -f 1`
    if [ "${PLATFORM/.}" != "$PLATFORM" ] ; then
      MINOR=`echo $PLATFORM | cut -d '.' -f 2`
    fi
    CGO_NTDEF="-D_WIN32_WINNT=0x`printf "%02d" $MAJOR``printf "%02d" $MINOR`"

    # Build the requested windows binaries
    if [ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]; then
      echo "Compiling for windows-$PLATFORM/amd64..."
      CC=x86_64-w64-mingw32-gcc-posix CXX=x86_64-w64-mingw32-g++-posix HOST=x86_64-w64-mingw32 PREFIX=/usr/x86_64-w64-mingw32 $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/x86_64-w64-mingw32/lib/pkgconfig

      CC=x86_64-w64-mingw32-gcc-posix CXX=x86_64-w64-mingw32-g++-posix GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CGO_CFLAGS="$CGO_NTDEF" CGO_CXXFLAGS="$CGO_NTDEF" go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=x86_64-w64-mingw32-gcc-posix CXX=x86_64-w64-mingw32-g++-posix GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CGO_CFLAGS="$CGO_NTDEF" CGO_CXXFLAGS="$CGO_NTDEF" go build $V $X "${T[@]}" --ldflags="$V $LD" $R $BM -o "/build/$NAME-windows-$PLATFORM-amd64$R`extension windows`" ./$PACK
    fi
    if [ $XGOARCH == "." ] || [ $XGOARCH == "386" ]; then
      echo "Compiling for windows-$PLATFORM/386..."
      CC=i686-w64-mingw32-gcc-posix CXX=i686-w64-mingw32-g++-posix HOST=i686-w64-mingw32 PREFIX=/usr/i686-w64-mingw32 $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      export PKG_CONFIG_PATH=/usr/i686-w64-mingw32/lib/pkgconfig

      CC=i686-w64-mingw32-gcc-posix CXX=i686-w64-mingw32-g++-posix GOOS=windows GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="$CGO_NTDEF" CGO_CXXFLAGS="$CGO_NTDEF" go get $V $X "${T[@]}" --ldflags="$V $LD" -d ./$PACK
      CC=i686-w64-mingw32-gcc-posix CXX=i686-w64-mingw32-g++-posix GOOS=windows GOARCH=386 CGO_ENABLED=1 CGO_CFLAGS="$CGO_NTDEF" CGO_CXXFLAGS="$CGO_NTDEF" go build $V $X "${T[@]}" --ldflags="$V $LD" $BM -o "/build/$NAME-windows-$PLATFORM-386`extension windows`" ./$PACK
    fi
  fi
  # Check and build for OSX targets
  if [ $XGOOS == "." ] || [[ $XGOOS == darwin* ]]; then
    # Split the platform version and configure the deployment target
    PLATFORM=`echo $XGOOS | cut -d '-' -f 2`
    if [ "$PLATFORM" == "" ] || [ "$PLATFORM" == "." ] || [ "$PLATFORM" == "darwin" ]; then
      PLATFORM=10.6 # OS X Snow Leopard
    fi
    export MACOSX_DEPLOYMENT_TARGET=$PLATFORM

    # Strip symbol table below Go 1.6 to prevent DWARF issues
    LDSTRIP=""
    if [ "$GO_VERSION" -lt 160 ]; then
      LDSTRIP="-s"
    fi
    # Build the requested darwin binaries
    if [ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]; then
      echo "Compiling for darwin-$PLATFORM/amd64..."
      CC=o64-clang CXX=o64-clang++ HOST=x86_64-apple-darwin15 PREFIX=/usr/local $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$LDSTRIP $V $LD" -d ./$PACK
      CC=o64-clang CXX=o64-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$LDSTRIP $V $LD" $R $BM -o "/build/$NAME-darwin-$PLATFORM-amd64$R`extension darwin`" ./$PACK
    fi
    if [ $XGOARCH == "." ] || [ $XGOARCH == "386" ]; then
      echo "Compiling for darwin-$PLATFORM/386..."
      CC=o32-clang CXX=o32-clang++ HOST=i386-apple-darwin15 PREFIX=/usr/local $BUILD_DEPS /deps ${DEPS_ARGS[@]}
      CC=o32-clang CXX=o32-clang++ GOOS=darwin GOARCH=386 CGO_ENABLED=1 go get $V $X "${T[@]}" --ldflags="$LDSTRIP $V $LD" -d ./$PACK
      CC=o32-clang CXX=o32-clang++ GOOS=darwin GOARCH=386 CGO_ENABLED=1 go build $V $X "${T[@]}" --ldflags="$LDSTRIP $V $LD" $BM -o "/build/$NAME-darwin-$PLATFORM-386`extension darwin`" ./$PACK
    fi
    # Remove any automatically injected deployment target vars
    unset MACOSX_DEPLOYMENT_TARGET
  fi
  # Check and build for iOS targets
  if [ $XGOOS == "." ] || [[ $XGOOS == ios* ]]; then
    # Split the platform version and configure the deployment target
    PLATFORM=`echo $XGOOS | cut -d '-' -f 2`
    if [ "$PLATFORM" == "" ] || [ "$PLATFORM" == "." ] || [ "$PLATFORM" == "ios" ]; then
      PLATFORM=5.0 # first iPad and upwards
    fi
    export IPHONEOS_DEPLOYMENT_TARGET=$PLATFORM

    # Build the requested iOS binaries
    if [ "$GO_VERSION" -lt 150 ]; then
      echo "Go version too low, skipping ios..."
    else
      # Add the 'ios' tag to all builds, otherwise the std libs will fail
      if [ "$FLAG_TAGS" != "" ]; then
        IOSTAGS=(--tags "ios $FLAG_TAGS")
      else
        IOSTAGS=(--tags ios)
      fi
      mkdir -p /build-ios-fw

      # Strip symbol table below Go 1.6 to prevent DWARF issues
      LDSTRIP=""
      if [ "$GO_VERSION" -lt 160 ]; then
        LDSTRIP="-s"
      fi
      # Cross compile to all available iOS and simulator platforms
      if [ -d "$IOS_NDK_ARM_7" ] && ([ $XGOARCH == "." ] || [ $XGOARCH == "arm-7" ] || [ $XGOARCH == "framework" ]); then
        echo "Bootstrapping ios-$PLATFORM/arm-7..."
        export PATH=$IOS_NDK_ARM_7/bin:$PATH
        GOOS=darwin GOARCH=arm GOARM=7 CGO_ENABLED=1 CC=arm-apple-darwin11-clang go install --tags ios std

        echo "Compiling for ios-$PLATFORM/arm-7..."
        CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ HOST=arm-apple-darwin11 PREFIX=/usr/local $BUILD_DEPS /deps ${DEPS_ARGS[@]}
        CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=arm GOARM=7 CGO_ENABLED=1 go get $V $X "${IOSTAGS[@]}" --ldflags="$V $LD" -d ./$PACK
        if [ $XGOARCH == "." ] || [ $XGOARCH == "arm-7" ]; then
          CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=arm GOARM=7 CGO_ENABLED=1 go build $V $X "${IOSTAGS[@]}" --ldflags="$LDSTRIP $V $LD" $BM -o "/build/$NAME-ios-$PLATFORM-armv7`extension darwin`" ./$PACK
        fi
        if [ $XGOARCH == "." ] || [ $XGOARCH == "framework" ]; then
          CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=arm GOARM=7 CGO_ENABLED=1 go build $V $X "${IOSTAGS[@]}" --ldflags="$V $LD" --buildmode=c-archive -o "/build-ios-fw/$NAME-ios-$PLATFORM-armv7.a" ./$PACK
        fi
        echo "Cleaning up Go runtime for ios-$PLATFORM/arm-7..."
        rm -rf /usr/local/go/pkg/darwin_arm
      fi
      if [ -d "$IOS_NDK_ARM64" ] && ([ $XGOARCH == "." ] || [ $XGOARCH == "arm64" ] || [ $XGOARCH == "framework" ]); then
        echo "Bootstrapping ios-$PLATFORM/arm64..."
        export PATH=$IOS_NDK_ARM64/bin:$PATH
        GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 CC=arm-apple-darwin11-clang go install --tags ios std

        echo "Compiling for ios-$PLATFORM/arm64..."
        CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ HOST=arm-apple-darwin11 PREFIX=/usr/local $BUILD_DEPS /deps ${DEPS_ARGS[@]}
        CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 go get $V $X "${IOSTAGS[@]}" --ldflags="$V $LD" -d ./$PACK
        if [ $XGOARCH == "." ] || [ $XGOARCH == "arm64" ]; then
          CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 go build $V $X "${IOSTAGS[@]}" --ldflags="$LDSTRIP $V $LD" $BM -o "/build/$NAME-ios-$PLATFORM-arm64`extension darwin`" ./$PACK
        fi
        if [ $XGOARCH == "." ] || [ $XGOARCH == "framework" ]; then
          CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=arm64 CGO_ENABLED=1 go build $V $X "${IOSTAGS[@]}" --ldflags="$V $LD" --buildmode=c-archive -o "/build-ios-fw/$NAME-ios-$PLATFORM-arm64.a" ./$PACK
        fi
        echo "Cleaning up Go runtime for ios-$PLATFORM/arm64..."
        rm -rf /usr/local/go/pkg/darwin_arm64
      fi
      if [ -d "$IOS_SIM_NDK_AMD64" ] && ([ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ] || [ $XGOARCH == "framework" ]); then
        echo "Bootstrapping ios-$PLATFORM/amd64..."
        export PATH=$IOS_SIM_NDK_AMD64/bin:$PATH
        mv /usr/local/go/pkg/darwin_amd64 /usr/local/go/pkg/darwin_amd64_bak
        GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 CC=arm-apple-darwin11-clang go install --tags ios std

        echo "Compiling for ios-$PLATFORM/amd64..."
        CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ HOST=arm-apple-darwin11 PREFIX=/usr/local $BUILD_DEPS /deps ${DEPS_ARGS[@]}
        CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go get $V $X "${IOSTAGS[@]}" --ldflags="$V $LD" -d ./$PACK
        if [ $XGOARCH == "." ] || [ $XGOARCH == "amd64" ]; then
          CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build $V $X "${IOSTAGS[@]}" --ldflags="$LDSTRIP $V $LD" $BM -o "/build/$NAME-ios-$PLATFORM-x86_64`extension darwin`" ./$PACK
        fi
        if [ $XGOARCH == "." ] || [ $XGOARCH == "framework" ]; then
          CC=arm-apple-darwin11-clang CXX=arm-apple-darwin11-clang++ GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build $V $X "${IOSTAGS[@]}" --ldflags="$V $LD" --buildmode=c-archive -o "/build-ios-fw/$NAME-ios-$PLATFORM-x86_64.a" ./$PACK
        fi
        echo "Cleaning up Go runtime for ios-$PLATFORM/amd64..."
        rm -rf /usr/local/go/pkg/darwin_amd64
        mv /usr/local/go/pkg/darwin_amd64_bak /usr/local/go/pkg/darwin_amd64
      fi
      # Assemble the iOS framework from the built binaries
      if [ $XGOARCH == "." ] || [ $XGOARCH == "framework" ]; then
        title=${NAME^}
        framework=/build/$NAME-ios-$PLATFORM-framework/$title.framework

        rm -rf $framework
        mkdir -p $framework/Versions/A
        (cd $framework/Versions && ln -nsf A Current)

        arches=()
        for lib in `ls /build-ios-fw | grep -e '\.a$'`; do
          arches+=("-arch" "`echo ${lib##*-} | cut -d '.' -f 1`" "/build-ios-fw/$lib")
        done
        arm-apple-darwin11-lipo -create "${arches[@]}" -o $framework/Versions/A/$title
        arm-apple-darwin11-ranlib $framework/Versions/A/$title
        (cd $framework && ln -nsf Versions/A/$title $title)

        mkdir -p $framework/Versions/A/Headers
        for header in `ls /build-ios-fw | grep -e '\.h$'`; do
          cp -f /build-ios-fw/$header $framework/Versions/A/Headers/$title.h
        done
        (cd $framework && ln -nsf Versions/A/Headers Headers)

        mkdir -p $framework/Versions/A/Resources
        echo -e "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n</dict>\n</plist>" > $framework/Versions/A/Resources/Info.plist
        (cd $framework && ln -nsf Versions/A/Resources Resources)

        mkdir -p $framework/Versions/A/Modules
        echo -e "framework module \"$title\" {\n  header \"$title.h\"\n  export *\n}" > $framework/Versions/A/Modules/module.modulemap
        (cd $framework && ln -nsf Versions/A/Modules Modules)

        chmod 777 -R /build/$NAME-ios-$PLATFORM-framework
      fi
      rm -rf /build-ios-fw
    fi
    # Remove any automatically injected deployment target vars
    unset IPHONEOS_DEPLOYMENT_TARGET
  fi
done

# Clean up any leftovers for subsequent build invocations
echo "Cleaning up build environment..."
rm -rf /deps

for dir in `ls /usr/local`; do
  keep=0

  # Check against original folder contents
  for old in $USR_LOCAL_CONTENTS; do
    if [ "$old" == "$dir" ]; then
      keep=1
    fi
  done
  # Delete anything freshly generated
  if [ "$keep" == "0" ]; then
    rm -rf "/usr/local/$dir"
  fi
done
