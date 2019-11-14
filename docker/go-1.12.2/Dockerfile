# Go cross compiler (xgo): Go 1.12.2
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11202

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.2.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=f28c1fde8f293cc5c83ae8de76373cf76ae9306909564f54e0edcf140ce8fe3f && \
  \
  $BOOTSTRAP_PURE
