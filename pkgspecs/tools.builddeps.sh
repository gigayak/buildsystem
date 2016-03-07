#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Need wget and tar to download and extract source.
dep wget
dep tar

# Some packages require a native GCC to build utilities which are then used
# during the package build process.
dep gcc
dep gcc-c++

# binutils requires texinfo
if [[ "$YAK_PKG_NAME" == "binutils" ]]
then
  dep texinfo
fi

# as does e2fsprogs
if [[ "$YAK_PKG_NAME" == "e2fsprogs" ]]
then
  dep texinfo
fi

# GRUB wants flex and bison.
if [[ "$YAK_PKG_NAME" == "grub" || "$YAK_PKG_NAME" == "iproute2" ]]
then
  dep bison
  dep flex
fi

# Busybox wants to statically link in glibc.
if [[ "$YAK_PKG_NAME" == "busybox" ]]
then
  dep --arch="$YAK_TARGET_ARCH" --distro="$YAK_TARGET_OS" "glibc"
fi

# Add all cross-compilation toolchain packages in as build-time dependencies.
for p in \
  file m4 ncurses pkg-config-lite gmp mpfr mpc isl cloog \
  binutils gcc bc
do
  dep --arch="$YAK_TARGET_ARCH" --distro=cross "$p"
done
dep --arch="$YAK_TARGET_ARCH" --distro="$YAK_TARGET_OS" "linux-headers"
