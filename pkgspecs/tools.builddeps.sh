#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Need wget and tar to download and extract source.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" wget
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar

# Some packages require a native GCC to build utilities which are then used
# during the package build process.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gcc
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" automake
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" autoconf
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" make

# binutils requires texinfo
if [[ "$YAK_PKG_NAME" == "binutils" ]]
then
  dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" texinfo
fi

# as does e2fsprogs
if [[ "$YAK_PKG_NAME" == "e2fsprogs" ]]
then
  dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" texinfo
fi

# GRUB wants flex and bison.
if [[ "$YAK_PKG_NAME" == "grub" || "$YAK_PKG_NAME" == "iproute2" ]]
then
  dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" bison
  dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" flex
fi

# Busybox wants to statically link in glibc.
if [[ "$YAK_PKG_NAME" == "busybox" ]]
then
  dep --arch="$YAK_TARGET_ARCH" --distro="$YAK_TARGET_OS" "glibc"
fi

# Several packages want diffutils for cmp
if [[ \
  "$YAK_PKG_NAME" == "gcc" \
  || "$YAK_PKG_NAME" == "linux" \
  || "$YAK_PKG_NAME" == "grub" \
]]
then
  dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" "diffutils"
fi

# We use CLFS patches for some packages - so they should install patch.
if [[ "$YAK_PKG_NAME" == "bootscripts" ]]
then
  dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" "patch"
fi

# Add all cross-compilation toolchain packages in as build-time dependencies.
for p in \
  file m4 ncurses pkg-config-lite gmp mpfr mpc isl cloog \
  binutils gcc bc
do
  dep --arch="$YAK_TARGET_ARCH" --distro=cross "$p"
done
dep --arch="$YAK_TARGET_ARCH" --distro="$YAK_TARGET_OS" "linux-headers"
