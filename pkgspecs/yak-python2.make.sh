#!/bin/bash
set -Eeo pipefail

cd /root
version=2.7.10
echo "$version" > /root/version
url="https://www.python.org/ftp/python/$version/Python-$version.tgz"
wget --no-check-certificate "$url"
tar -xf *.tgz

cd *-*/
./configure \
  --prefix=/usr
make
