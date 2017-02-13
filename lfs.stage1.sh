#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

source "$(DIR)/cleanup.sh"
source "$(DIR)/escape.sh"
source "$(DIR)/flag.sh"
source "$(DIR)/log.sh"

add_flag --default="" architecture "Architecture to build for.  Default: host"
add_flag --default="" start_from "Package to start build with.  Default: first"
parse_flags "$@"

log_rote "this script builds all of Linux."
start_from="$F_start_from"
waiting=0
if [[ ! -z "$start_from" ]]
then
  waiting=1
fi

target_arch="$arch"
if [[ -z "$target_arch" ]]
then
  target_arch="$("$(DIR)/os_info.sh" --arch)"
fi

logdir="$(select_temp_root)/yak_logs/stage1"
log_rote "saving build logs to $(sq "$logdir")"
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
      && "${arch}-${distro}-${pkg}" != "$start_from" \
      && "${distro}-${pkg}" != "$start_from" ]]
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
build yak internal-ca-certificates
build yak stage3-certificate

# And no joke, we generate the tools version of the Mozilla CA certificate
# package from the final version, rather than the other way around.  Either
# could go first, I suppose, but yak-ca-certificates existed first, and doing
# a full rebuild (to test the inversion) would take a long time (~40 hours)
# right now.  So you have this comment instead.
# TODO: This could totally be cleaned up if someone has a few CPU-days to test.
build yak ca-certificates
build tools ca-certificates
build tools2 ca-certificates

# The buildsystem config is just copied over from the host system, so we copy
# it as close to the source as possible.  This prevents weird automated config
# overrides made by the buildsystem from accidentally propagating into the
# final image.
build yak buildsystem-config

echo "Everything finished!  Woo-hoo!"
