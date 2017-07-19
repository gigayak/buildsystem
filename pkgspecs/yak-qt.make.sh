#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"

version=5.9.1
echo "$version" > "$YAK_WORKSPACE/version"
major_version="$(echo "$version" | sed -re 's@\.[^.]+$@@')"
url_dir="http://download.qt.io/official_releases/qt/$major_version/$version"
url="$url_dir/single/qt-everywhere-opensource-src-${version}.tar.xz"
wget "$url"
tar -Jxf *.tar.xz
cd *-*/
./configure --prefix=/usr --opensource --confirm-license 2>&1 | tee ~/log
make -j 8
