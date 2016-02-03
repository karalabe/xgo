# Go cross compiler (xgo): Go 1.6 release candidate 1 layer
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.6rc1.linux-amd64.tar.gz  && \
  export ROOT_DIST_SHA=6a8aeab9548faf933a66dafeb809bd8623c5bba1ca9626c2f28ef619b5723218 && \
  \
  $BOOTSTRAP_PURE

ENV GO_VERSION 160
