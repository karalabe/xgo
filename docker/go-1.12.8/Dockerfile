# Go cross compiler (xgo): Go 1.12.8
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11208

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.8.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=bd26cd4962a362ed3c11835bca32c2e131c2ae050304f2c4df9fa6ded8db85d2 && \
  \
  $BOOTSTRAP_PURE
