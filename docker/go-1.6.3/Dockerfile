# Go cross compiler (xgo): Go 1.6.3
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 163

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=cdde5e08530c0579255d6153b08fdb3b8e47caabbe717bc7bcd7561275a87aeb && \
  \
  $BOOTSTRAP_PURE
