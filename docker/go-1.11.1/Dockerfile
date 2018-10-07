# Go cross compiler (xgo): Go 1.11.1
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1111

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.1.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=2871270d8ff0c8c69f161aaae42f9f28739855ff5c5204752a8d92a1c9f63993 && \
  \
  $BOOTSTRAP_PURE
