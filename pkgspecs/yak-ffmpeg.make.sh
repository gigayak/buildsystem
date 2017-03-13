#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="3.2.4"
echo "$version" > version
url="http://ffmpeg.org/releases/ffmpeg-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*
cd *-*/
./configure \
  --prefix=/usr \
  --enable-shared
make
