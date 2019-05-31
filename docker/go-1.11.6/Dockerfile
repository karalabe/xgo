# Go cross compiler (xgo): Go 1.11.6
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1116

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.6.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=4e1864282d8d20010d6385a12a1e35641783a380a7c57907bfb46a5499c5eb49 && \
  \
  $BOOTSTRAP_PURE
