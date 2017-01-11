# Go cross compiler (xgo): Go 1.7.4
# Copyright (c) 2017 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 174

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=47fda42e46b4c3ec93fa5d4d4cc6a748aa3f9411a2a2b7e08e3a6d80d753ec8b && \
  \
  $BOOTSTRAP_PURE
