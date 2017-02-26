#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=0.3.2
echo "$version" > version
source "$YAK_BUILDTOOLS/download.sh"
download_sourceforge "mpg321/mpg321/${version}/mpg321_${version}.orig.tar.gz"
tar -xf *.tar.*
cd */

./configure --prefix=/usr

make
