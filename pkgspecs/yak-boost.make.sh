#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="1.63.0"
echo "$version" > version
source "$YAK_BUILDTOOLS/download.sh"
version_underscored="$(echo "$version" | tr '.' '_')"
download_sourceforge "boost/boost/$version/boost_${version_underscored}.tar.gz"
tar -xf *.tar.*
cd boost_*/
# Temporary build directory - shouldn't use root Boost directory, similar to
# gcc build...
mkdir -pv "$YAK_WORKSPACE/build"
b2 --build-dir="$YAK_WORKSPACE/build" toolset=gcc stage
