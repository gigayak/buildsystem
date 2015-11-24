#!/bin/bash
set -Eeo pipefail

version="3.3.11"
without_revision="$(echo "$version" | sed -re 's@\.[0-9]+$@@')"
echo "$version" > /root/version
basedir="ftp://ftp.gnutls.org/gcrypt/gnutls/v$without_revision"
url="$basedir/gnutls-${version}.tar.xz"

cd /root
wget "$url"
tar -Jxf "gnutls-$version.tar.xz"
cd "gnutls-$version"

./configure --prefix=/usr
make

# Do not allow info files to be installed.
#
# /usr/share/info/dir is a single file to hold an index, and is incompatible
# with file-based package management.
rm -rf /usr/share/info
