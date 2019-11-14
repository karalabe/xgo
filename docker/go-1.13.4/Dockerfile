# Go cross compiler (xgo): Go 1.13.4
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11304

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.13.4.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=692d17071736f74be04a72a06dab9cac1cd759377bd85316e52b2227604c004c && \
  \
  $BOOTSTRAP_PURE
