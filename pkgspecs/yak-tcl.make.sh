#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

source "$YAK_BUILDTOOLS/download.sh"
cd "$YAK_WORKSPACE"
version=8.6.4
echo "$version" > "$YAK_WORKSPACE/version"
download_sourceforge "tcl/Tcl/$version/tcl$version-src.tar.gz"

tar -zxf *.tar.gz
cd "$YAK_WORKSPACE"/tcl*/
cd unix
./configure --prefix=/usr
make

