#!/bin/bash
set -e

custompath=/hacks:$PATH:/go/bin
PATH=$custompath gomobile "$@"
