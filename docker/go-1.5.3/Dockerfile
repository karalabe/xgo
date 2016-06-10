# Go cross compiler (xgo): Go 1.5.3 layer
# Copyright (c) 2015 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 153

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=43afe0c5017e502630b1aea4d44b8a7f059bf60d7f29dfd58db454d4e4e0ae53 && \
  \
  $BOOTSTRAP_PURE
