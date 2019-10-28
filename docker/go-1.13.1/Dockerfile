# Go cross compiler (xgo): Go 1.13
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM mysteriumnetwork/xgo:base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

ENV CGO_LDFLAGS_ALLOW -fobjc-arc
ENV GO_VERSION 1131

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=94f874037b82ea5353f4061e543681a0e79657f787437974214629af8407d124 && \
  \
  $BOOTSTRAP_PURE
