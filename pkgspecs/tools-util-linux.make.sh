#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=2.26
echo "$version" > "$YAK_WORKSPACE/version"
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
#
#
# Options derived locally:
#
# --disable-kill prevents kill from building, which overlaps with coreutils.
# Not doing this causes both packages to conflict from claiming the same files.
./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET" \
  --disable-makeinstall-chown \
  --disable-makeinstall-setuid \
  --without-python \
  --without-systemdsystemunitdir \
  --disable-kill

make
