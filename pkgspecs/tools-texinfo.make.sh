#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cd /root
version=5.2
echo "$version" > /root/version
url="http://ftp.gnu.org/gnu/texinfo/texinfo-$version.tar.gz"
wget "$url"

tar -zxf "texinfo-$version.tar.gz"
cd texinfo-*/

# Ensure we point at /usr/bin even if perl is installed to /bin
# TODO: Why? This was suggested by CLFS...
export PERL=/usr/bin/perl

./configure \
  --prefix=/tools/i686 \
  --build="$CLFS_HOST" \
  --host="$CLFS_TARGET"

make -C tools/gnulib/lib
make -C tools/info/ makedoc # http://patchwork.openembedded.org/patch/72171/
make
