# Go cross compiler (xgo): Go 1.5.4 layer
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 154

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.5.4.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=a3358721210787dc1e06f5ea1460ae0564f22a0fbd91be9dcd947fb1d19b9560 && \
  \
  $BOOTSTRAP_PURE
