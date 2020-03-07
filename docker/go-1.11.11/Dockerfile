# Go cross compiler (xgo): Go 1.11.11
# Copyright (c) 2020 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11111

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.11.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=2fd47b824d6e32154b0f6c8742d066d816667715763e06cebb710304b195c775 && \
  \
  $BOOTSTRAP_PURE
