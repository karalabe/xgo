#!/usr/bin/env bash
#Usage: ./goGetForked.sh https://github.com/tadovas/mobile.git golang.org/x/mobile [optional subpackage to go install]
#Will checkout forked git repo to folder specified by second arg and will do go install on it

set -e

if [ ! -z "$3" ]; then subpackage="/$3"; fi

git clone $1 $GOPATH/src/$2
go install $2${subpackage}
