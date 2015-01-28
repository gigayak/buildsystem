#!/bin/bash
set -Eeo pipefail

cd /root
version=3.18.3
echo "$version" > /root/version
url="https://www.kernel.org/pub/linux/kernel/v3.x/linux-$version.tar.xz"
wget "$url"

tar -Jxf "linux-$version.tar.xz"
cd "linux-$version"
make mrproper
make ARCH=i386 headers_check
