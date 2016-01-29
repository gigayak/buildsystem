#!/bin/bash
set -Eeo pipefail

cd /root
version=5.9
echo "$version" > /root/version
url="http://ftp.gnu.org/pub/gnu/ncurses/ncurses-$version.tar.gz"
wget "$url"

tar -zxf "ncurses-$version.tar.gz"
cd "ncurses-$version"

# I removed --libdir=/lib to see if it would fix autoconf not finding ncurses
./configure \
  --prefix=/usr \
  --with-shared \
  --enable-widec \
  --with-manpage-format=normal \
  --enable-pc-files \
  --with-default-terminfo-dir=/usr/share/terminfo

make
