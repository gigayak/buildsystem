#!/bin/bash
set -Eeo pipefail

cd /root
version=8.6.4
echo "$version" > /root/version
wget "http://downloads.sourceforge.net/project/tcl/Tcl/$version/tcl$version-src.tar.gz"

tar -zxf *.tar.gz
cd /root/*/
cd unix
./configure --prefix=/tools/i686
make

