#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=8.6.4
echo "$version" > "$YAK_WORKSPACE/version"
source "$YAK_BUILDTOOLS/download.sh"
download_sourceforge "tcl/Tcl/$version/tcl$version-src.tar.gz"

tar -zxf *.tar.gz
cd "$YAK_WORKSPACE"/tcl*/
cd unix
./configure --prefix=/tools/i686
make

