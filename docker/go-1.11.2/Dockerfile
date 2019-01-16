# Go cross compiler (xgo): Go 1.11.2
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1112

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.2.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=1dfe664fa3d8ad714bbd15a36627992effd150ddabd7523931f077b3926d736d && \
  \
  $BOOTSTRAP_PURE
