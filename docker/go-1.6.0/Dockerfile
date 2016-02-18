# Go cross compiler (xgo): Go 1.6
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz       && \
  export ROOT_DIST_SHA=5470eac05d273c74ff8bac7bef5bad0b5abbd1c4052efbdbc8db45332e836b0b && \
  \
  $BOOTSTRAP_PURE

ENV GO_VERSION 160
