#!/usr/bin/env bash
set -e

docker run --rm \
    -v "$PWD"/build:/build \
    -v "$GOPATH"/.xgo-cache:/deps-cache:ro \
    -v "$PWD"/src:/ext-go/1/src:ro \
    -e OUT=Mysterium \
    -e FLAG_V=false \
    -e FLAG_X=false \
    -e FLAG_RACE=false \
    -e FLAG_BUILDMODE=default \
    -e TARGETS=android/. \
    -e EXT_GOPATH=/ext-go/1 \
    -e GO111MODULE=off \
    mysteriumnetwork/xgomobile:1.13.8 mobilepkg
