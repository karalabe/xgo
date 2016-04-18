#!/bin/bash
#
# Contains a simple tool that updates some of the iOS toolchains with the SDKs
# explicitly provided. The goal is to allow using your own up to date SDKs or
# the simulator one not supported out of the box.
#
# Usage: update_ios.sh <path to>/<iSomething><Version>.sdk.tar.<type>
set -e

# Figure out the base name of the SDK
sdk=`basename $1`
sdk=${sdk%.*}
sdk=${sdk%.*}

# Define a small extraction utility to
function extract {
  case $1 in
    *.tar.xz)
      xz -dc $1 | tar xf -
      ;;
    *.tar.gz)
      gunzip -dc $1 | tar xf -
      ;;
    *.tar.bz2)
      bzip2 -dc $1 | tar xf -
      ;;
  esac
}

# Extract the SDK, patch it, clean it up and prep for bootstrapping
extract $1

if [[ "`basename $1`" =~ ^iPhoneSimulator ]]; then
  echo "Patching iOS simulator SDK with missing libraries..."
  ln -s $OSX_NDK_X86/SDK/$OSX_SDK/usr/lib/system/libsystem_kernel.dylib   $sdk/usr/lib/system/libsystem_kernel.dylib
  ln -s $OSX_NDK_X86/SDK/$OSX_SDK/usr/lib/system/libsystem_platform.dylib $sdk/usr/lib/system/libsystem_platform.dylib
  ln -s $OSX_NDK_X86/SDK/$OSX_SDK/usr/lib/system/libsystem_pthread.dylib  $sdk/usr/lib/system/libsystem_pthread.dylib
  ln -s $OSX_NDK_X86/SDK/$OSX_SDK/usr/lib/system/libsystem_kernel.tbd     $sdk/usr/lib/system/libsystem_kernel.tbd
  ln -s $OSX_NDK_X86/SDK/$OSX_SDK/usr/lib/system/libsystem_platform.tbd   $sdk/usr/lib/system/libsystem_platform.tbd
  ln -s $OSX_NDK_X86/SDK/$OSX_SDK/usr/lib/system/libsystem_pthread.tbd    $sdk/usr/lib/system/libsystem_pthread.tbd
fi

tar -czf /tmp/$sdk.tar.gz $sdk
rm -rf $sdk

# Pull the iOS cross compiler tool and build the toolchain
git clone https://github.com/tpoechtrager/cctools-port.git

if [[ "`basename $1`" =~ ^iPhoneSimulator ]]; then
  rm -rf $IOS_SIM_NDK_AMD64
  /cctools-port/usage_examples/ios_toolchain/build.sh /tmp/$sdk.tar.gz x86_64
  mv /cctools-port/usage_examples/ios_toolchain/target $IOS_SIM_NDK_AMD64
else
  rm -rf $IOS_NDK_ARM_7 $IOS_NDK_ARM64
  /cctools-port/usage_examples/ios_toolchain/build.sh /tmp/$sdk.tar.gz armv7
  mv /cctools-port/usage_examples/ios_toolchain/target $IOS_NDK_ARM_7
  /cctools-port/usage_examples/ios_toolchain/build.sh /tmp/$sdk.tar.gz arm64
  mv /cctools-port/usage_examples/ios_toolchain/target $IOS_NDK_ARM64
fi

rm -rf /cctools-port
