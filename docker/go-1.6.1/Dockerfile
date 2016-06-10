# Go cross compiler (xgo): Go 1.6.1
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 161

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.6.1.linux-amd64.tar.gz     && \
  export ROOT_DIST_SHA=6d894da8b4ad3f7f6c295db0d73ccc3646bce630e1c43e662a0120681d47e988 && \
  \
  $BOOTSTRAP_PURE
