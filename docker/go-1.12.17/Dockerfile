# Go cross compiler (xgo): Go 1.12.17
# Copyright (c) 2020 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11217

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.17.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=a53dd476129d496047487bfd53d021dd17e0c96895865a0e7d0469ce3db8c8d2 && \
  \
  $BOOTSTRAP_PURE
