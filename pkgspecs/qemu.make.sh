#!/bin/bash
set -Eeo pipefail

cd /root
version=2.2.0
echo "$version" > /root/version
url="http://wiki.qemu-project.org/download/qemu-$version.tar.bz2"
wget "$url"

tar -jxf "qemu-$version.tar.bz2"
cd "qemu-$version"
./configure --prefix=/usr
make
