#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version="0.15.2"
echo "$version" > version
url="http://nim-lang.org/download/nim-${version}.tar.xz"
download "$url"
tar -xf *.tar.*
cd *-*/
./build.sh
