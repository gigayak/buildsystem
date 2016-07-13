#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"

version="8.6.9"
echo "$version" > version
download_sourceforge "asciidoc/asciidoc/${version}/asciidoc-${version}.tar.gz"
tar -xf *.tar.*


cd */
./configure \
  --prefix=/usr
make
