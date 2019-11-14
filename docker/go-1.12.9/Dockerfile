# Go cross compiler (xgo): Go 1.12.9
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11209

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.9.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=ac2a6efcc1f5ec8bdc0db0a988bb1d301d64b6d61b7e8d9e42f662fbb75a2b9b && \
  \
  $BOOTSTRAP_PURE
