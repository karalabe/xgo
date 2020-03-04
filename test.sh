#!/usr/bin/env bash
set -e

docker run --rm \
    -v "$PWD"/build:/build \
    -v "$PWD":/app \
    -w /app \
    -e OUT=Mysterium \
    -e FLAG_V=false \
    -e FLAG_X=false \
    -e FLAG_RACE=false \
    -e FLAG_BUILDMODE=default \
    -e TARGETS=android/. \
    mysteriumnetwork/xgomobile:1.13.8 ./testlib
