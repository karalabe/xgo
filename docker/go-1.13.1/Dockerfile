# Go cross compiler (xgo): Go 1.13.1
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11301

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.13.1.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=94f874037b82ea5353f4061e543681a0e79657f787437974214629af8407d124 && \
  \
  $BOOTSTRAP_PURE
