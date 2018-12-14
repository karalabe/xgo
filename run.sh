#!/usr/bin/env bash
set -e

function buildBase() {
    echo "Building base..."
    docker build -t mysteriumnetwork/xgo:base $@ docker/base/.
}

function buildGo() {
    local tag=$1
    shift;
    echo "Building go... will tag as $tag"
    docker build -t mysteriumnetwork/xgo-$tag $@ docker/go-1.11.0/.
}

function xgoTest() {
    local tag=$1
    shift;
    echo "Running tests... using tag: $tag"
    xgo -image=mysteriumnetwork/xgo-$tag -targets=android/*,ios/* $@ -out mobilepkg -dest `pwd`/artifacts \
    --ldflags="-w -s -X mobilepkg.Flag=success2" \
    `pwd`/src/mobilepkg
}

function listAarFiles() {
    local file=$1
    unzip -l $file
}

cmd="$1"
shift
echo "Running $cmd ... with args $@"
$cmd $@
