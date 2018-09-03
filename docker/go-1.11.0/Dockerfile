# Go cross compiler (xgo): Go 1.11
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1110

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.linux-amd64.tar.gz      && \
  export ROOT_DIST_SHA=b3fcf280ff86558e0559e185b601c9eade0fd24c900b4c63cd14d1d38613e499 && \
  \
  $BOOTSTRAP_PURE
