# Go cross compiler (xgo): Go 1.11.8
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1118

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.8.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=e32ab1c934b747999d04e8a550b97f4647f8b1b43e152de5650d4476bfd1d2e1 && \
  \
  $BOOTSTRAP_PURE
