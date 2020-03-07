# Go cross compiler (xgo): Go 1.12.15
# Copyright (c) 2020 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11215

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.15.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=61068419f3d3fcd3cc415c352c4a93d6ae0e723ac18a22ac572b4904d78b5a4c && \
  \
  $BOOTSTRAP_PURE
