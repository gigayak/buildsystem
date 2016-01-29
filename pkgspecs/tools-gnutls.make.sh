#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

version="3.3.11"
echo "$version" > /root/version
url="ftp://ftp.gnutls.org/gcrypt/gnutls/v3.3/gnutls-3.3.11.tar.xz"

cd /root
wget "$url"
tar -Jxf "gnutls-$version.tar.xz"
cd "gnutls-$version"

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}" \
  --with-default-trust-store-dir=/tools/i686/etc/ssl/certs
make

# Do not allow info files to be installed.
#
# /usr/share/info/dir is a single file to hold an index, and is incompatible
# with file-based package management.
rm -rf /tools/i686/share/info
