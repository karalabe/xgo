# Go cross compiler (xgo): Go 1.13.6
# Copyright (c) 2020 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11306

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.13.6.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=a1bc06deb070155c4f67c579f896a45eeda5a8fa54f35ba233304074c4abbbbd && \
  \
  $BOOTSTRAP_PURE
