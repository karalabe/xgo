# Go cross compiler (xgo): Go 1.10
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1100

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.10.linux-amd64.tar.gz      && \
  export ROOT_DIST_SHA=b5a64335f1490277b585832d1f6c7f8c6c11206cba5cd3f771dcb87b98ad1a33 && \
  \
  $BOOTSTRAP_PURE
