#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

# API change incompatible with qt5, breaks phantomjs's submodule qt5 build
#version=59.1
version=58.2
echo "$version" > "$YAK_WORKSPACE/version"
version_underscored="$(echo "$version" | tr . _)"
urldir="http://download.icu-project.org/files/icu4c/$version"
url="$urldir/icu4c-${version_underscored}-src.tgz"
wget "$url"
tar -xf *.tgz
cd icu/source/
./configure --prefix=/usr
make -j 8
