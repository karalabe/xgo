# Go cross compiler (xgo): Go 1.6 beta 2 layer
# Copyright (c) 2015 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.6beta2.linux-amd64.tar.gz  && \
  export ROOT_DIST_SHA=7ddf9797c7baaac2c16eed1a8d42f9a446223301c7dc8771ea805f211828e6a5 && \
  \
  $BOOTSTRAP_PURE

ENV GO_VERSION 160
