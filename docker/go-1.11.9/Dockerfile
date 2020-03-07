# Go cross compiler (xgo): Go 1.11.9
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11109

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.9.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=e88aa3e39104e3ba6a95a4e05629348b4a1ec82791fb3c941a493ca349730608 && \
  \
  $BOOTSTRAP_PURE
