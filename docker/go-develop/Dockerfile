# Go cross compiler (xgo): Go develop layer
# Copyright (c) 2015 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Clone and bootstrap the latest Go develop branch
RUN $BOOTSTRAP_REPO master
ENV GO_VERSION 999
