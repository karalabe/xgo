# Go cross compiler (xgo): Go 1.7.5
# Copyright (c) 2017 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 175

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.7.5.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=2e4dd6c44f0693bef4e7b46cc701513d74c3cc44f2419bf519d7868b12931ac3 && \
  \
  $BOOTSTRAP_PURE
