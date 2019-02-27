FROM techknowlogick/xgo:base

# Configure the root Go distribution and bootstrap based on it
ENV GO_VERSION 1120

RUN \
  export ROOT_DIST=https://storage.googleapis.com/golang/go1.12.linux-amd64.tar.gz    && \
  export ROOT_DIST_SHA=3ac1db65a6fa5c13f424b53ee181755429df0c33775733cede1e0d540440fd7b && \
  \
  $BOOTSTRAP_PURE
