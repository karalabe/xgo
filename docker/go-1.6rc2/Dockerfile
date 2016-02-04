# Go cross compiler (xgo): Go 1.6 release candidate 2 layer
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.6rc2.linux-amd64.tar.gz  && \
  export ROOT_DIST_SHA=9c19fa0fe32ee9bff79123d47147a5fd15fec451806bf5644a01173a86a8a4b9 && \
  \
  $BOOTSTRAP_PURE

ENV GO_VERSION 160
