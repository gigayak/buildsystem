#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=3.0-20140710
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.clfs.org/pub/clfs/conglomeration/bootscripts-cross-lfs/bootscripts-cross-lfs-$version.tar.xz"
wget "$url"
tar -Jxf "bootscripts-cross-lfs-$version.tar.xz"
