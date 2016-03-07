#!/bin/bash
set -Eeo pipefail

cd "$YAK_WORKSPACE"
version=8.23
echo "$version" > "$YAK_WORKSPACE/version"
url="http://ftp.gnu.org/gnu/coreutils/coreutils-$version.tar.xz"
wget "$url"

tar -Jxf "coreutils-$version.tar.xz"
cd coreutils-*/

# FORCE_UNSAFE_CONFIGURE makes configure run as uid 0, as it has an
# explicit check to see if you're compiling as root.
FORCE_UNSAFE_CONFIGURE=1 \
./configure \
  --prefix=/usr \
  --libexecdir=/usr/lib \
  --enable-no-install-program=kill,uptime \
  --enable-install-program=hostname

make
