# Go cross compiler (xgo): Go 1.9.4
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 194

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.9.4.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=15b0937615809f87321a457bb1265f946f9f6e736c563d6c5e0bd2c22e44f779 && \
  \
  $BOOTSTRAP_PURE
