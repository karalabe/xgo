# Go cross compiler (xgo): Go 1.13
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM mysteriumnetwork/xgomobile:base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

ENV CGO_LDFLAGS_ALLOW -fobjc-arc
ENV GO_VERSION 1136

RUN \
  export ROOT_DIST=https://dl.google.com/go/go1.13.6.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA=a1bc06deb070155c4f67c579f896a45eeda5a8fa54f35ba233304074c4abbbbd && \
  \
$BOOTSTRAP_PURE