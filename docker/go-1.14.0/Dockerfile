# Go cross compiler (xgo): Go 1.14
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11400

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.14.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=08df79b46b0adf498ea9f320a0f23d6ec59e9003660b4c9c1ce8e5e2c6f823ca && \
  \
  $BOOTSTRAP_PURE
