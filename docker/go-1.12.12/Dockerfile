# Go cross compiler (xgo): Go 1.12.12
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11212

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.12.linux-amd64.tar.gz   && \
  export ROOT_DIST_SHA=4cf11ac6a8fa42d26ab85e27a5d916ee171900a87745d9f7d4a29a21587d78fc && \
  \
  $BOOTSTRAP_PURE
