# Go cross compiler (xgo): Go 1.13.5
# Copyright (c) 2020 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11305

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.13.5.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=512103d7ad296467814a6e3f635631bd35574cab3369a97a323c9a585ccaa569 && \
  \
  $BOOTSTRAP_PURE
