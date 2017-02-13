#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Include all /tools/ packages we've compiled so far as dependencies.
# This dependency list should be the same as the build order from lfs.stage1.sh
# with glibc prefixed.
for p in \
  glibc \
  gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check coreutils \
  diffutils file findutils gawk gettext grep gzip make patch sed tar texinfo \
  util-linux xz bootscripts e2fsprogs kmod shadow sysvinit eudev linux grub \
  gcc-aliases bash-aliases coreutils-aliases grep-aliases file-aliases \
  sysvinit-aliases shadow-aliases linux-aliases linux-devices \
  linux-credentials linux-fstab-cd linux-fstab-hd linux-log-directories \
  bash-profile iproute2 dhcp dhcp-config dropbear dropbear-config nettle \
  libtasn1 gnutls internal-ca-certificates ca-certificates \
  wget rsync buildsystem linux-mountpoints busybox \
  initrd linux-firmware gigayak-installer stage2-certificate go-sget \
  buildsystem-config
do
  if [[ "$YAK_PKG_NAME" == "$p" ]]
  then
    exit 0
  fi

  # Never emit a kernel dependency.  Kernel dependencies are dependencies
  # on a process running (the kernel) rather than a file.  Consider what
  # happens when a container needs a kernel of a certain version: it can't
  # just drop in a new kernel and have it magically work.
  #
  # TODO: We need to figure out a way to do kernel dependencies properly...
  if [[ "$YAK_PKG_NAME" == "linux" ]]
  then
    continue
  fi

  dep --arch="$YAK_TARGET_ARCH" --distro="$YAK_TARGET_OS" "$p"

  if [[
    ( \
      "$YAK_PKG_NAME" == "linux-fstab-cd" \
      || "$YAK_PKG_NAME" == "linux-fstab-hd" \
    ) \
    && "$p" == "linux" \
  ]]
  then
    exit 0
  fi
done
