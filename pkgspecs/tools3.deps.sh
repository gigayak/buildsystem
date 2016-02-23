#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Include all /tools/ packages we've compiled so far as dependencies.
for p in \
  glibc \
  gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check coreutils \
  diffutils file findutils gawk gettext grep gzip make patch sed tar texinfo \
  util-linux xz bootscripts e2fsprogs kmod shadow sysvinit eudev linux grub \
  gcc-aliases bash-aliases coreutils-aliases grep-aliases \
  file-aliases sysvinit-aliases shadow-aliases linux-aliases linux-devices \
  linux-credentials linux-log-directories bash-profile \
  iproute2 dhcp dhcp-config dropbear dropbear-config nettle gnutls \
  internal-ca-certificates wget rsync buildsystem
do
  if [[ "$PKG_NAME" == "$p" && "$TARGET_OS" == "tools2" ]]
  then
    exit 0
  fi
  dep --arch="$TARGET_ARCH" --distro=tools2 "$p"
done

for p in \
  tcl expect dejagnu perl
do
  if [[ "$PKG_NAME" == "$p" && "$TARGET_OS" == "tools3" ]]
  then
    exit 0
  fi
  dep --arch="$TARGET_ARCH" --distro=tools3 "$p"
done
