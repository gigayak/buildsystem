#!/bin/bash
set -Eeo pipefail

# Include all /tools/ packages we've compiled so far as dependencies.
for p in \
  root env glibc \
  gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check coreutils \
  diffutils file findutils gawk gettext grep gzip make patch sed tar texinfo \
  util-linux xz bootscripts e2fsprogs kmod shadow sysvinit eudev linux grub \
  gcc-aliases bash-aliases coreutils-aliases grep-aliases \
  file-aliases sysvinit-aliases shadow-aliases linux-aliases linux-devices \
  linux-credentials linux-fstab linux-log-directories bash-profile \
  iproute2 dhcp dhcp-config dropbear dropbear-config nettle gnutls wget rsync \
  buildsystem
do
  if [[ "$PKG_NAME" == "i686-tools-$p" ]]
  then
    exit 0
  fi
  echo "i686-tools-$p"
done

for p in \
  tcl expect dejagnu perl
do
  if [[ "$PKG_NAME" == "i686-tools2-$p" ]]
  then
    exit 0
  fi
  echo "i686-tools2-$p"
done
