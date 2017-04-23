#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=2.29
echo "$version" > "$YAK_WORKSPACE/version"
# ftp is used here because kernel.org insists on HTTPS, and we don't have CA certs
# installed during stage2.
#
# TODO: Install CA certs in stage2 image.
url="ftp://ftp.kernel.org/pub/linux/utils/util-linux/v$version/util-linux-$version.tar.gz"
wget "$url"

tar -zxf "util-linux-$version.tar.gz"
cd util-linux-*/

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

# --libdir here is /lib or /lib64 so that e2fsprogs, which installs to /bin,
# can make use of them.
./configure \
  ADJTIME_PATH=/var/lib/hwclock/adjtime \
  --enable-write \
  --libdir="/$lib" \
  --docdir="/usr/share/doc/util-linux-$version"

make
