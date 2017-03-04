#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=190600_20161030
echo "$version" > version
url="http://www.portaudio.com/archives/pa_stable_v${version}.tgz"
wget "$url"
tar -xf *.tgz
cd */
./configure --prefix=/usr
make
