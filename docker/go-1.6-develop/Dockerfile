# Go cross compiler (xgo): Go 1.6 develop layer
# Copyright (c) 2016 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Clone and bootstrap the latest Go develop branch
RUN $BOOTSTRAP_REPO release-branch.go1.6
ENV GO_VERSION 161
