#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version="6.0"
echo "$version" > version
major_version="$(echo "$version" | sed -re 's@\.[^\.]+$@\.x@g')"
nodot_version="$(echo "$version" | tr -d '.')"
urldir="infozip/UnZip%20${major_version}%20%28latest%29/UnZip%20${version}"
url="$urldir/unzip${nodot_version}.tar.gz"
download_sourceforge "$url"
tar -xf *.tar.*
cd */
make -f unix/Makefile generic
