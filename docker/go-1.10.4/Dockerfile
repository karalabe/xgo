# Go cross compiler (xgo): Go 1.10.4
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1104

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.10.4.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=fa04efdb17a275a0c6e137f969a1c4eb878939e91e1da16060ce42f02c2ec5ec && \
  \
  $BOOTSTRAP_PURE
