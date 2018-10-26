#!/usr/bin/env bash
set -e

function buildBase() {
    echo "Building base..."
    docker build -t mysteriumnetwork/xgo:base $@ docker/base/.
}

function buildGo() {
    echo "Building go..."
    docker build -t mysteriumnetwork/xgo-1.11 $@ docker/go-1.11.0/.
}

function xgoTest() {
    echo "Running tests..."
    xgo -image=mysteriumnetwork/xgo-1.11 -targets=ios/arm64,android/arm64 -x -v -out mobilepkg -dest `pwd`/artifacts `pwd`/src/mobilepkg
}

cmd="$1"
shift
echo "Running $cmd ... with args $@"
$cmd $@
