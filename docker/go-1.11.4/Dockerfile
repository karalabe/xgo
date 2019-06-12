# Go cross compiler (xgo): Go 1.11.4
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1114

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.4.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=fb26c30e6a04ad937bbc657a1b5bba92f80096af1e8ee6da6430c045a8db3a5b && \
  \
  $BOOTSTRAP_PURE
