#!/bin/bash
set -Eeo pipefail

cd /root
version=1.28
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/tar/tar-${version}.tar.gz"
wget "$url"
tar -xf *.tar.*

cd *-*/
# ./configure doesn't want to run as root, and the buildsystem demands to run
# as root... so FORCE_UNSAFE_CONFIGURE is ./configure's way of being told to
# just deal with it...
FORCE_UNSAFE_CONFIGURE=1 \
./configure \
  --prefix=/usr \
  --bindir=/bin \
  --libexecdir=/usr/sbin
make
