# Go cross compiler (xgo): Go 1.11.5
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1115

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.5.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=ff54aafedff961eb94792487e827515da683d61a5f9482f668008832631e5d25 && \
  \
  $BOOTSTRAP_PURE
