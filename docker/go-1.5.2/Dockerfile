# Go cross compiler (xgo): Go 1.5.2 layer
# Copyright (c) 2015 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.5.2.linux-amd64.tar.gz && \
  export ROOT_DIST_SHA1=cae87ed095e8d94a81871281d35da7829bd1234e && \
  \
  $BOOTSTRAP_PURE

ENV GO_VERSION 152
