#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="1.63.0"
echo "$version" > version
source "$YAK_BUILDTOOLS/download.sh"
version_underscored="$(echo "$version" | tr '.' '_')"
download_sourceforge "boost/boost/$version/boost_${version_underscored}.tar.gz"
tar -xf *.tar.*
cd */
cd tools/build
./bootstrap.sh
