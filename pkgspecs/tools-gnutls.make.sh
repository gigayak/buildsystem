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
  --build="${CLFS_HOST}" \
  --host="${CLFS_TARGET}" \
  --libdir="/tools/${YAK_TARGET_ARCH}/$lib" \
  --without-p11-kit \
  --with-default-trust-store-dir="/tools/${YAK_TARGET_ARCH}/etc/ssl/certs"
make

# Do not allow info files to be installed.
#
# /usr/share/info/dir is a single file to hold an index, and is incompatible
# with file-based package management.
rm -rf "/tools/$YAK_TARGET_ARCH/share/info"
