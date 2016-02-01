#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

#version=3.1.1
version=2.7.1 # gnutls does not support 3.0 and up
echo "$version" > /root/version
url="https://ftp.gnu.org/gnu/nettle/nettle-$version.tar.gz"

cd /root
wget "$url"
tar -zxf *.tar.gz
cd *-*/

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}"
make

# Do not allow info files to be installed.
#
# /usr/share/info/dir is a single file to hold an index, and is incompatible
# with file-based package management.
#rm -rf /usr/share/info
