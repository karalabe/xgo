# Go cross compiler (xgo): Go 1.12.6
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11206

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.6.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=dbcf71a3c1ea53b8d54ef1b48c85a39a6c9a935d01fc8291ff2b92028e59913c && \
  \
  $BOOTSTRAP_PURE
