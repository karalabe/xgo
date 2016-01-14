#!/bin/bash
#
# Contains the Go tool-chain source repository bootstrapper, that builds and
# bootstraps a Go environment from the official GitHub repository, opposed to
# using pre-build packages.
#
# Usage: bootstrap_repo.sh <branch>
#
# Needed environment variables:
#   FETCH - Remote file fetcher and checksum verifier (injected by image)
set -e

# Define the paths to deploy the bootstrapper and the final distribution
export GOROOT=/usr/local/go
export GOROOT_BOOTSTRAP=${GOROOT}-boot

# Download and install the Go bootstrap distribution
BOOT_DIST=https://storage.googleapis.com/golang/go1.4.3.linux-amd64.tar.gz
BOOT_DIST_SHA=332b64236d30a8805fc8dd8b3a269915b4c507fe

$FETCH $BOOT_DIST $BOOT_DIST_SHA

tar -C /usr/local -xzf `basename $BOOT_DIST`
rm -f `basename $BOOT_DIST`
mv $GOROOT $GOROOT_BOOTSTRAP

# Download, build and install the requesed Go sources
(cd /usr/local && git clone https://go.googlesource.com/go)
(cd $GOROOT && git checkout $1)
(cd $GOROOT/src && ./make.bash)

rm -rf $GOROOT_BOOTSTRAP
export GOROOT_BOOTSTRAP=$GOROOT

$BOOTSTRAP_PURE
