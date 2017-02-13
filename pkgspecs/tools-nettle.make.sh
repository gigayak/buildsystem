#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

version=3.2
echo "$version" > "$YAK_WORKSPACE/version"
url="https://ftp.gnu.org/gnu/nettle/nettle-$version.tar.gz"

cd "$YAK_WORKSPACE"
wget "$url"
tar -zxf *.tar.gz
cd *-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

./configure \
  --prefix="/tools/${YAK_TARGET_ARCH}" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make

# Do not allow info files to be installed.
#
# /usr/share/info/dir is a single file to hold an index, and is incompatible
# with file-based package management.
#rm -rf /usr/share/info
