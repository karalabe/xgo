# Go cross compiler (xgo): Go 1.6.2
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 162

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.6.2.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=e40c36ae71756198478624ed1bb4ce17597b3c19d243f3f0899bb5740d56212a && \
  \
  $BOOTSTRAP_PURE
