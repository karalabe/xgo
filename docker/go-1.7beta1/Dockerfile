# Go cross compiler (xgo): Go 1.7beta1
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 170

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.7beta1.linux-amd64.tar.gz  && \
  export ROOT_DIST_SHA=a55e718935e2be1d5b920ed262fd06885d2d7fc4eab7722aa02c205d80532e3b && \
  \
  $BOOTSTRAP_PURE
