# Go cross compiler (xgo): Go 1.6 beta 1 layer
# Copyright (c) 2015 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.6beta1.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA1=5c02222a5ab348ae0f9244df95dea71781953749 && \
  \
  $BOOTSTRAP_PURE

ENV GO_VERSION 160
