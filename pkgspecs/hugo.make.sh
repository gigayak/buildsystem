#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version="0.35"
echo "$version" > version
url="https://github.com/gohugoio/hugo/archive/v${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
mv *-*/ hugo

# For whatever reason, the buildsystem doesn't wind up sourcing
# this file.
#
# TODO: Investigate what happens when buildsystem pops a shell
# and how it relates to this bug...
source /etc/profile.d/go.sh

mkdir -pv goworkspace/{bin,src/github.com/gohugoio}
export GOPATH="$PWD/goworkspace"
mv hugo goworkspace/src/github.com/gohugoio/

cd goworkspace/src/github.com/gohugoio/hugo
dep ensure
go install github.com/gohugoio/hugo
