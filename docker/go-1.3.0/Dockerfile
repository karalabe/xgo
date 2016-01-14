# Go cross compiler (xgo): Go 1.3.0 layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the Go packages and bootstrap them
RUN \
  export DIST_LINUX_64=https://storage.googleapis.com/golang/go1.3.linux-amd64.tar.gz && \
  export DIST_LINUX_64_SHA=b6b154933039987056ac307e20c25fa508a06ba6 && \
  \
  export DIST_LINUX_32=https://storage.googleapis.com/golang/go1.3.linux-386.tar.gz && \
  export DIST_LINUX_32_SHA=22db33b0c4e242ed18a77b03a60582f8014fd8a6 && \
  \
  export DIST_LINUX_ARM=http://dave.cheney.net/paste/go.1.3.linux-arm~armv5-1.tar.gz && \
  export DIST_LINUX_ARM_SHA=fc059c970a059757778b157b1140a3c56eb1a069 && \
  \
  export DIST_OSX_64=https://storage.googleapis.com/golang/go1.3.darwin-amd64-osx10.6.tar.gz && \
  export DIST_OSX_64_SHA=82ffcfb7962ca7114a1ee0a96cac51c53061ea05 && \
  \
  export DIST_OSX_32=https://storage.googleapis.com/golang/go1.3.darwin-386-osx10.6.tar.gz && \
  export DIST_OSX_32_SHA=159d2797bee603a80b829c4404c1fb2ee089cc00 && \
  \
  export DIST_WIN_64=https://storage.googleapis.com/golang/go1.3.windows-amd64.zip && \
  export DIST_WIN_64_SHA=1e4888e1494aed7f6934acb5c4a1ffb0e9a022b1 && \
  \
  export DIST_WIN_32=https://storage.googleapis.com/golang/go1.3.windows-386.zip && \
  export DIST_WIN_32_SHA=e4e5279ce7d8cafdf210a522a70677d5b9c7589d && \
  \
  $BOOTSTRAP

ENV GO_VERSION 130
