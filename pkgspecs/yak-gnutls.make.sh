#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"

version="3.4.13"
echo "$version" > "version"
major="$(echo "$version" | cut -d. -f1,2)"
urldir="https://www.gnupg.org/ftp/gcrypt/gnutls/v${major}"
url="${urldir}/gnutls-${version}.tar.xz"

wget --no-check-certificate "$url"
tar -Jxf "gnutls-$version.tar.xz"
cd *-*/

# TODO: support polkit and remove --without-p11-kit flag
./configure \
  --prefix=/usr \
  --without-p11-kit \
  --with-default-trust-store-dir=/etc/ssl/certs
make

# Do not allow info files to be installed.
#
# /usr/share/info/dir is a single file to hold an index, and is incompatible
# with file-based package management.
rm -rf /usr/share/info
