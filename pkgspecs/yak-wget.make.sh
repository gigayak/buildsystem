#!/bin/bash
set -Eeo pipefail

cd /root
version=1.17
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/wget/wget-${version}.tar.xz"
wget "$url"
tar -xf *.tar.*
cd *-*/

./configure \
  --prefix=/usr
make
