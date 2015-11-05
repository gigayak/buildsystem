#!/bin/bash
set -Eeo pipefail

version=3.9.2
echo "$version" > /root/version
cd /root
version_id="3090200" # WTF?  TODO: derive this
url="https://www.sqlite.org/2015/sqlite-autoconf-${version_id}.tar.gz"
wget "$url"
tar -zxf *.tar.gz
cd */
./configure \
  --prefix=/usr
make
