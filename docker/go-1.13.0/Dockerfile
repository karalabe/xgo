# Go cross compiler (xgo): Go 1.13
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11300

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.13.linux-amd64.tar.gz      && \
  export ROOT_DIST_SHA=68a2297eb099d1a76097905a2ce334e3155004ec08cdea85f24527be3c48e856 && \
  \
  $BOOTSTRAP_PURE
