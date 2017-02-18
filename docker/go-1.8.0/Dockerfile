# Go cross compiler (xgo): Go 1.8
# Copyright (c) 2017 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 180

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz       && \
  export ROOT_DIST_SHA=53ab94104ee3923e228a2cb2116e5e462ad3ebaeea06ff04463479d7f12d27ca && \
  \
  $BOOTSTRAP_PURE
