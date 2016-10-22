# Go cross compiler (xgo): Go 1.7.3
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 173

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=508028aac0654e993564b6e2014bf2d4a9751e3b286661b0b0040046cf18028e && \
  \
  $BOOTSTRAP_PURE
