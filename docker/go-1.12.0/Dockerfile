# Go cross compiler (xgo): Go 1.12
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11200

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.linux-amd64.tar.gz      && \
  export ROOT_DIST_SHA=750a07fef8579ae4839458701f4df690e0b20b8bcce33b437e4df89c451b6f13 && \
  \
  $BOOTSTRAP_PURE
