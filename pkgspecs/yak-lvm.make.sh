#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"
version="2.2.02.160"
echo "$version" > version
url="ftp://sources.redhat.com/pub/lvm2/releases/LVM${version}.tgz"
wget "$url"
tar -xf *.tgz
cd */
./configure --prefix=/usr
make
