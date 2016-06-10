# Go cross compiler (xgo): Go 1.5.1 layer
# Copyright (c) 2015 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 151

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.5.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=46eecd290d8803887dec718c691cc243f2175fe0 && \
  \
  $BOOTSTRAP_PURE
