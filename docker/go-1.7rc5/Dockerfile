# Go cross compiler (xgo): Go 1.7rc5
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 170

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.7rc5.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=2ddf9f553aefe91d96dd3f13be55159869a221fd0111cd211dccf2cab3ee5e4a && \
  \
  $BOOTSTRAP_PURE
