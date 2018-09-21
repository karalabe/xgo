# Go cross compiler (xgo): Go 1.10.2
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1102

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.10.2.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=4b677d698c65370afa33757b6954ade60347aaca310ea92a63ed717d7cb0c2ff && \
  \
  $BOOTSTRAP_PURE
