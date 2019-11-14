# Go cross compiler (xgo): Go 1.12.11
# Copyright (c) 2019 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 11211

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.11.linux-amd64.tar.gz   && \
  export ROOT_DIST_SHA=2c5960292da8b747d83f171a28a04116b2977e809169c344268c893e4cf0a857 && \
  \
  $BOOTSTRAP_PURE
