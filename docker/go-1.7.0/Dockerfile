# Go cross compiler (xgo): Go 1.7
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 170

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.7.linux-amd64.tar.gz       && \
  export ROOT_DIST_SHA=702ad90f705365227e902b42d91dd1a40e48ca7f67a2f4b2fd052aaa4295cd95 && \
  \
  $BOOTSTRAP_PURE
