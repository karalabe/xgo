# Go cross compiler (xgo): Go 1.12.16
# Copyright (c) 2020 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11216

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.16.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=bf3a85d75658144c06ce986ba05e07ef08af4320089b74b1d41de3b0f340ea7e && \
  \
  $BOOTSTRAP_PURE
