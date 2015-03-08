#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=2.26
echo "$version" > /root/version
url="https://www.kernel.org/pub/linux/utils/util-linux/v$version/util-linux-$version.tar.gz"
wget "$url"

tar -zxf "util-linux-$version.tar.gz"
cd util-linux-*/

# Options from latest LFS book:
#
# --without-python prevents make from failing due to Python when Python is
# present on the host system.  yum requires Python - so this prevents failures
# on yum-based distros.
#
# --without-systemdsystemunitdir prevents systemd spam, since we're a System V
# init shop.
#
#
# Options from CLFS book:
#
# --disable-makeinstall-chown prevents attempts to chown files during install.
# The world is root for our temporary system.
#
# --disable-makeinstall-setuid prevents the sticky bit from being set for any
# binaries.  Not sure what failures this would cause, though.
./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --disable-makeinstall-chown \
  --disable-makeinstall-setuid \
  --without-python \
  --without-systemdsystemunitdir

make
