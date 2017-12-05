# Go cross compiler (xgo): Go 1.9
# Copyright (c) 2017 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 191

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.9.1.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=07d81c6b6b4c2dcf1b5ef7c27aaebd3691cdb40548500941f92b221147c5d9c7 && \
  \
  $BOOTSTRAP_PURE
