#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"
version=2.1
echo "$version" > "$YAK_WORKSPACE/version"
url="https://dev.gentoo.org/~blueness/eudev/eudev-2.1.tar.gz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

case $YAK_TARGET_ARCH in
x86_64|amd64)
  lib=lib # lib64 in multilib
  ;;
*)
  lib=lib
  ;;
esac

cd *-*/
# TODO: WOW THIS COMMANDLINE IS LONG.  Can it be shortened?
./configure \
  --prefix=/usr \
  --sysconfdir=/etc \
  --with-rootprefix="" \
  --libexecdir="/$lib" \
  --enable-split-usr \
  --libdir="/usr/$lib" \
  --with-rootlibdir="/$lib" \
  --sbindir="/sbin" \
  --bindir="/sbin" \
  --enable-rule_generator \
  --disable-introspection \
  --disable-keymap \
  --disable-gudev \
  --disable-gtk-doc-html \
  --with-firmware-path="/$lib/firmware" \
  --enable-libkmod
make
