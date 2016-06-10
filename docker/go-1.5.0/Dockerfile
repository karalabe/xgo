# Go cross compiler (xgo): Go 1.5.0 layer
# Copyright (c) 2015 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 150

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.5.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=5817fa4b2252afdb02e11e8b9dc1d9173ef3bd5a && \
  \
  $BOOTSTRAP_PURE
