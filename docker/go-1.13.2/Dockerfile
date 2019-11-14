# Go cross compiler (xgo): Go 1.13.2
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11302

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.13.2.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=293b41a6ccd735eebcfb4094b6931bfd187595555cecf3e4386e9e119220c0b7 && \
  \
  $BOOTSTRAP_PURE
