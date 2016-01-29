#!/bin/bash
set -Eeo pipefail

cd /root
version=2.1
echo "$version" > /root/version
url="https://dev.gentoo.org/~blueness/eudev/eudev-2.1.tar.gz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd *-*/
# TODO: WOW THIS COMMANDLINE IS LONG.  Can it be shortened?
./configure \
  --prefix=/usr \
  --sysconfdir=/etc \
  --with-rootprefix="" \
  --libexecdir=/lib \
  --enable-split-usr \
  --libdir=/usr/lib \
  --with-rootlibdir=/lib \
  --sbindir=/sbin \
  --bindir=/sbin \
  --enable-rule_generator \
  --disable-introspection \
  --disable-keymap \
  --disable-gudev \
  --disable-gtk-doc-html \
  --with-firmware-path=/lib/firmware \
  --enable-libkmod
make
