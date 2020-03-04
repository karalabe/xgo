#!/bin/bash
#
# Contains the main cross compiler, that individually sets up each target build
# platform, compiles all the C dependencies, then build the requested executable
# itself.
#
# Usage: build.sh <import path>
#
# Needed environment variables:
#   OUT            - Optional output prefix to override the package name
#   FLAG_V         - Optional verbosity flag to set on the Go builder
#   FLAG_X         - Optional flag to print the build progress commands
#   FLAG_RACE      - Optional race flag to set on the Go builder
#   FLAG_TAGS      - Optional tag flag to set on the Go builder
#   FLAG_LDFLAGS   - Optional ldflags flag to set on the Go builder
#   FLAG_BUILDMODE - Optional buildmode flag to set on the Go builder
#   TARGETS        - Comma separated list of build targets to compile for
#   GO_VERSION     - Bootstrapped version of Go to disable uncupported targets

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

# Save the contents of the pre-build /usr/local folder for post cleanup
USR_LOCAL_CONTENTS=`ls /usr/local`

# Configure some global build parameters
PACK_RELPATH=$1
NAME=`basename $1/$PACK_RELPATH`
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
    # Ignore android versions etc. build only archive and sources
    # Android api will be 21 for arm64, 16 for arm-a7v
    # Archive will be for both amd64,x86 and arm64, arm 7
    $GOMOBILE bind --target=android/arm64,android/arm,android/amd64,android/386 $X $V "${T[@]}" --ldflags="$V $LD" -o "/build/$NAME.aar" ./$PACK_RELPATH
  fi

  # Check and build for iOS targets
  if [ $XGOOS == "." ] || [[ $XGOOS == ios* ]]; then
    # Split the platform version and configure the deployment target
    PLATFORM=`echo $XGOOS | cut -d '-' -f 2`
    if [ "$PLATFORM" == "" ] || [ "$PLATFORM" == "." ] || [ "$PLATFORM" == "ios" ]; then
      PLATFORM=10.3 #min ios version to build for
    fi

    $GOMOBILE bind --target=ios/arm64 -iosversion=$PLATFORM $X $V "${T[@]}" --ldflags="$V $LD" -o "/build/$NAME.framework" ./$PACK_RELPATH
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
