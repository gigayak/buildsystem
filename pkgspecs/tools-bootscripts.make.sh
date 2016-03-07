#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=3.0-20140710
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.clfs.org/pub/clfs/conglomeration/bootscripts-cross-lfs/bootscripts-cross-lfs-$version.tar.xz"
wget "$url"
tar -Jxf "bootscripts-cross-lfs-$version.tar.xz"

patch="tools_updates-2.patch"
url="http://ftp.clfs.org/pub/clfs/conglomeration/bootscripts-cross-lfs/bootscripts-cross-lfs-$version-$patch"
wget "$url"

cd bootscripts-cross-lfs-*/
patch -Np1 -i "../bootscripts-cross-lfs-$version-$patch"

while read -r path
do
  sed \
    -r \
    -e 's@(/tools)@\1/i686@g' \
    -i "$path"
done < <(grep /tools . --recursive --files-with-matches)
