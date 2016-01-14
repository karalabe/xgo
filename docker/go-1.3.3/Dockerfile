# Go cross compiler (xgo): Go 1.3.3 layer
# Copyright (c) 2014 Péter Szilágyi. All rights reserved.
#
# Released under the MIT license.

FROM karalabe/xgo-base

MAINTAINER Péter Szilágyi <peterke@gmail.com>

# Configure the Go packages and bootstrap them
RUN \
  export DIST_LINUX_64=https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz && \
  export DIST_LINUX_64_SHA=14068fbe349db34b838853a7878621bbd2b24646 && \
  \
  export DIST_LINUX_32=https://storage.googleapis.com/golang/go1.3.3.linux-386.tar.gz && \
  export DIST_LINUX_32_SHA=9eb426d5505de55729e2656c03d85722795dd85e && \
  \
  export DIST_LINUX_ARM=http://dave.cheney.net/paste/go.1.3.3.linux-arm~armv5-1.tar.gz && \
  export DIST_LINUX_ARM_SHA=78789a5e3288d9e86e0cd667e6588775594eae87 && \
  \
  export DIST_OSX_64=https://storage.googleapis.com/golang/go1.3.3.darwin-amd64-osx10.6.tar.gz && \
  export DIST_OSX_64_SHA=dfe68de684f6e8d9c371d01e6d6a522efe3b8942 && \
  \
  export DIST_OSX_32=https://storage.googleapis.com/golang/go1.3.3.darwin-386-osx10.6.tar.gz && \
  export DIST_OSX_32_SHA=04b3e38549183e984f509c07ad40d8bcd577a702 && \
  \
  export DIST_WIN_64=https://storage.googleapis.com/golang/go1.3.3.windows-amd64.zip && \
  export DIST_WIN_64_SHA=5f0b3b104d3db09edd32ef1d086ba20bafe01ada && \
  \
  export DIST_WIN_32=https://storage.googleapis.com/golang/go1.3.3.windows-386.zip && \
  export DIST_WIN_32_SHA=ba99083b22e0b22b560bb2d28b9b99b405d01b6b && \
  \
  $BOOTSTRAP

ENV GO_VERSION 133
