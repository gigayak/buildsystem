#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

version="3.4.13"
echo "$version" > "$YAK_WORKSPACE/version"
major="$(echo "$version" | cut -d. -f1,2)"
urldir="https://www.gnupg.org/ftp/gcrypt/gnutls/v${major}"
url="${urldir}/gnutls-${version}.tar.xz"

cd "$YAK_WORKSPACE"
wget "$url"
tar -Jxf "gnutls-$version.tar.xz"
cd "gnutls-$version"

./configure \
  --prefix=/tools/i686 \
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}" \
  --without-p11-kit \
  --with-default-trust-store-dir=/tools/i686/etc/ssl/certs
make

# Do not allow info files to be installed.
#
# /usr/share/info/dir is a single file to hold an index, and is incompatible
# with file-based package management.
rm -rf /tools/i686/share/info
