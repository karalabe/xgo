# Go cross compiler (xgo): Go 1.11.3
# Copyright (c) 2018 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1113

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.11.3.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=d20a4869ffb13cee0f7ee777bf18c7b9b67ef0375f93fac1298519e0c227a07f && \
  \
  $BOOTSTRAP_PURE
