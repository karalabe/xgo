# Go cross compiler (xgo): Go 1.9.2
# Copyright (c) 2017 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 192

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=de874549d9a8d8d8062be05808509c09a88a248e77ec14eb77453530829ac02b && \
  \
  $BOOTSTRAP_PURE
