#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

echo "This script builds all of Linux."
start_from="$1"
waiting=0
if [[ ! -z "$start_from" ]]
then
  waiting=1
fi

target_arch=i686

logdir="/mnt/vol_b/tmp/logs"
mkdir -pv "$logdir"

build()
{
  if (( "$#" != 2 ))
  then
    echo "Usage: ${FUNCNAME[0]} <distro> <package>" >&2
    return 1
  fi
  local distro="$1"
  local pkg="$2"
  local arch="$target_arch"
  if (( "$waiting" )) \
    && [[ "$pkg" != "$start_from" \
      && "${arch}-${distro}-${pkg}" != "$start_from" ]]
  then
    echo "Ignoring package '$pkg'"
    return 0
  fi
  export waiting=0

  local p="${arch}-${distro}-${pkg}"
  echo "Building package '$p'"
  retval=0
  "$(DIR)/pkg.from_name.sh" \
    --pkg_name="$pkg" \
    --target_architecture="$arch" \
    --target_distribution="$distro" \
    2>&1 \
    | tee "$logdir/$p.log" \
    || retval=$?
  if (( "$retval" ))
  then
    echo "Building package '$p' failed with code $retval"
    exit 1
  fi
}

build clfs root
build cross root
build cross env
build tools root
build tools2 root
build tools env
build tools linux-headers
build tools2 linux-headers
build cross file
build cross m4
# implement "build"
# consider that pkg.from_name.sh has no OS/distro awareness
# consider that packages have no idea how to find packagespecs based on OS ID
for p in \
  file m4 \
  ncurses pkg-config-lite gmp mpfr mpc isl cloog \
  isl binutils gcc-static bc
do
  build cross "$p"
done
build tools glibc
build tools2 glibc
build cross gcc
for p in \
  gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check coreutils \
  diffutils file findutils gawk gettext grep gzip make patch sed tar texinfo \
  util-linux xz bootscripts e2fsprogs kmod shadow sysvinit eudev linux grub \
  gcc-aliases bash-aliases coreutils-aliases grep-aliases file-aliases \
  sysvinit-aliases shadow-aliases linux-aliases linux-devices \
  linux-credentials linux-fstab-cd linux-fstab-hd linux-log-directories \
  bash-profile iproute2 dhcp dhcp-config dropbear dropbear-config nettle \
  libtasn1 gnutls \
  internal-ca-certificates wget rsync buildsystem linux-mountpoints busybox \
  initrd linux-firmware gigayak-installer stage2-certificate go-sget \
  buildsystem-config
do
  build tools "$p"
  build tools2 "$p"
done
# Needed by all tools3 packages - can't be built by tools3, though.
# TODO: Can it?  It's .bootstrap.sh style, so it doesn't depend on itself.
build tools3 filesystem-skeleton
# Needed for sget to work, but must be built on system on which
# create_crypto.sh was run (for now).
build yak ca-certificates
build yak internal-ca-certificates
build yak stage3-certificate
build yak buildsystem-config

echo "Everything finished!  Woo-hoo!"
