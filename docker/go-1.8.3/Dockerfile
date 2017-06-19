# Go cross compiler (xgo): Go 1.8.3
# Copyright (c) 2017 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 183

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=1862f4c3d3907e59b04a757cfda0ea7aa9ef39274af99a784f5be843c80c6772 && \
  \
  $BOOTSTRAP_PURE
