#!/bin/bash
set -Eeo pipefail

cd /root
version=1.4.17
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/m4/m4-$version.tar.gz"
wget "$url"

tar -zxf "m4-$version.tar.gz"
cd "m4-$version"
./configure --prefix=/cross-tools/i686
make
