# Go cross compiler (xgo): Go 1.12.7
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11207

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.7.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=66d83bfb5a9ede000e33c6579a91a29e6b101829ad41fffb5c5bb6c900e109d9 && \
  \
  $BOOTSTRAP_PURE
