# Go cross compiler (xgo): Go 1.4 layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the Go packages and bootstrap them
RUN \
  export DIST_LINUX_64=https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz && \
  export DIST_LINUX_64_SHA=cd82abcb0734f82f7cf2d576c9528cebdafac4c6 && \
  \
  export DIST_LINUX_32=https://storage.googleapis.com/golang/go1.4.linux-386.tar.gz && \
  export DIST_LINUX_32_SHA=cb18d8122bfd3bbba20fa1a19b8f7566dcff795d && \
  \
  export DIST_LINUX_ARM=http://dave.cheney.net/paste/go1.4.linux-arm~armv5-1.tar.gz && \
  export DIST_LINUX_ARM_SHA=21039e81df30bf17fa5847d02892c425f0c37fc6 && \
  \
  export DIST_OSX_64=https://storage.googleapis.com/golang/go1.4.darwin-amd64-osx10.6.tar.gz && \
  export DIST_OSX_64_SHA=09621b9226abe12c2179778b015a33c1787b29d6 && \
  \
  export DIST_OSX_32=https://storage.googleapis.com/golang/go1.4.darwin-386-osx10.6.tar.gz && \
  export DIST_OSX_32_SHA=ee31cd0e26245d0e48f11667e4298e2e7f54f9b6 && \
  \
  export DIST_WIN_64=https://storage.googleapis.com/golang/go1.4.windows-amd64.zip && \
  export DIST_WIN_64_SHA=44f103d558b293919eb680041625c262dd00eb9a && \
  \
  export DIST_WIN_32=https://storage.googleapis.com/golang/go1.4.windows-386.zip && \
  export DIST_WIN_32_SHA=f44240a1750dd051476ae78e9ad0502bc5c7661d && \
  \
  $BOOTSTRAP

ENV GO_VERSION 140
