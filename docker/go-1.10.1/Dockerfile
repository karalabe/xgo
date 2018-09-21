# Go cross compiler (xgo): Go 1.10.1
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1101

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.10.1.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=72d820dec546752e5a8303b33b009079c15c2390ce76d67cf514991646c6127b && \
  \
  $BOOTSTRAP_PURE
