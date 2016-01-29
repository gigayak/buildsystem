#!/bin/bash
set -Eeo pipefail

cd /root
version=2.26
echo "$version" > /root/version
# ftp is used here because kernel.org insists on HTTPS, and we don't have CA certs
# installed during stage2.
#
# TODO: Install CA certs in stage2 image.
url="ftp://ftp.kernel.org/pub/linux/utils/util-linux/v$version/util-linux-$version.tar.gz"
wget "$url"

tar -zxf "util-linux-$version.tar.gz"
cd util-linux-*/

./configure \
  ADJTIME_PATH=/var/lib/hwclock/adjtime \
  --enable-write \
  --prefix=/usr \
  --docdir="/usr/share/doc/util-linux-$version"

make
