#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=1.1.3
echo "$version" > version
url="ftp://ftp.alsa-project.org/pub/lib/alsa-lib-${version}.tar.bz2"
wget "$url"
tar -xf *.tar.*
cd */
./configure --prefix=/usr
make
