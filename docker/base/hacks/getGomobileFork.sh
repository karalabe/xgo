#!/usr/bin/env bash

#use this fork until https://github.com/golang/mobile/pull/24 is accepted
git clone https://github.com/tadovas/mobile.git /go/src/golang.org/x/mobile
go install golang.org/x/mobile/cmd/gomobile