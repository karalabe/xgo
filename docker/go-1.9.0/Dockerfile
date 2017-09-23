# Go cross compiler (xgo): Go 1.9
# Copyright (c) 2017 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 190

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.9.linux-amd64.tar.gz       && \
  export ROOT_DIST_SHA=d70eadefce8e160638a9a6db97f7192d8463069ab33138893ad3bf31b0650a79 && \
  \
  $BOOTSTRAP_PURE
