# Go cross compiler (xgo): Go 1.13.3
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11303

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.13.3.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=0804bf02020dceaa8a7d7275ee79f7a142f1996bfd0c39216ccb405f93f994c0 && \
  \
  $BOOTSTRAP_PURE
