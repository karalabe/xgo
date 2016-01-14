# Go cross compiler (xgo): Go 1.3.1 layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the Go packages and bootstrap them
RUN \
  export DIST_LINUX_64=https://storage.googleapis.com/golang/go1.3.1.linux-amd64.tar.gz && \
  export DIST_LINUX_64_SHA=3af011cc19b21c7180f2604fd85fbc4ddde97143 && \
  \
  export DIST_LINUX_32=https://storage.googleapis.com/golang/go1.3.1.linux-386.tar.gz && \
  export DIST_LINUX_32_SHA=36f87ce21cdb4cb8920bb706003d8655b4e1fc81 && \
  \
  export DIST_LINUX_ARM= && \
  export DIST_LINUX_ARM_SHA= && \
  \
  export DIST_OSX_64=https://storage.googleapis.com/golang/go1.3.1.darwin-amd64-osx10.6.tar.gz && \
  export DIST_OSX_64_SHA=40716361d352c4b40252e79048e8bc084c3f3d1b && \
  \
  export DIST_OSX_32=https://storage.googleapis.com/golang/go1.3.1.darwin-386-osx10.6.tar.gz && \
  export DIST_OSX_32_SHA=84f70a4c83be24cea696654a5b55331ea32f8a3f && \
  \
  export DIST_WIN_64=https://storage.googleapis.com/golang/go1.3.1.windows-amd64.zip && \
  export DIST_WIN_64_SHA=4548785cfa3bc228d18d2d06e39f58f0e4e014f1 && \
  \
  export DIST_WIN_32=https://storage.googleapis.com/golang/go1.3.1.windows-386.zip && \
  export DIST_WIN_32_SHA=64f99e40e79e93a622e73d7d55a5b8340f07747f && \
  \
  $BOOTSTRAP

ENV GO_VERSION 131
