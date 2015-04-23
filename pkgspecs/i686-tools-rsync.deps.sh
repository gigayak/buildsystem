#!/bin/bash
set -Eeo pipefail

# Include all /tools/ packages we've compiled so far as dependencies.
for p in \
  root env glibc \
  gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check coreutils \
  diffutils file findutils gawk gettext grep gzip make patch sed tar texinfo \
  util-linux xz bootscripts e2fsprogs kmod shadow sysvinit eudev linux grub \
  dropbear
do
  if [[ "$PKG_NAME" == "i686-tools-$p" ]]
  then
    break
  fi
  echo "i686-tools-$p"
done
