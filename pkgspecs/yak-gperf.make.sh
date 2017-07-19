#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=3.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://ftp.gnu.org/gnu/gperf/gperf-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure --prefix=/usr
make
