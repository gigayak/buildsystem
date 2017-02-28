#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version=1.1.6
echo "$version" > version
source "$YAK_BUILDTOOLS/download.sh"
download_sourceforge \
  "fluidsynth/fluidsynth-${version}/fluidsynth-${version}.tar.gz"
tar -xf *.tar.*
cd */
./configure --prefix=/usr
make
