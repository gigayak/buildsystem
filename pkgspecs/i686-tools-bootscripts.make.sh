#!/bin/bash
set -Eeo pipefail

cd /root
version=3.0-20140710
echo "$version" > /root/version
url="http://ftp.clfs.org/pub/clfs/conglomeration/bootscripts-cross-lfs/bootscripts-cross-lfs-$version.tar.xz"
wget "$url"
tar -Jxf "bootscripts-cross-lfs-$version.tar.xz"

patch="tools_updates-2.patch"
url="http://ftp.clfs.org/pub/clfs/conglomeration/bootscripts-cross-lfs/bootscripts-cross-lfs-$version-$patch"
wget "$url"

cd bootscripts-cross-lfs-*/
patch -Np1 -i "../bootscripts-cross-lfs-$version-$patch"