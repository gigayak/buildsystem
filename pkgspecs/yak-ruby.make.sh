#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=2.4.1
echo "$version" > "$YAK_WORKSPACE/version"
major_version="$(echo "$version" | sed -Ee 's@\.[^.]*$@@')"
urldir="https://cache.ruby-lang.org/pub/ruby/$major_version"
url="$urldir/ruby-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
