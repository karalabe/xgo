# Go cross compiler (xgo): Go 1.8.1
# Copyright (c) 2017 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 181

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=a579ab19d5237e263254f1eac5352efcf1d70b9dacadb6d6bb12b0911ede8994 && \
  \
  $BOOTSTRAP_PURE
