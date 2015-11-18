#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Need wget and tar to download and extract source.
dep wget
dep tar

# Some packages require a native GCC to build utilities which are then used
# during the package build process.
dep gcc
dep gcc-c++

# binutils requires texinfo
if [[ "$PKG_NAME" == "i686-tools-binutils" ]]
then
  dep texinfo
fi

# as does e2fsprogs
if [[ "$PKG_NAME" == "i686-tools-e2fsprogs" ]]
then
  dep texinfo
fi

# GRUB wants flex and bison.
if [[ "$PKG_NAME" == "i686-tools-grub" || "$PKG_NAME" == "i686-tools-iproute2" ]]
then
  dep bison
  dep flex
fi

# Busybox wants to statically link in glibc.
if [[ "$PKG_NAME" == "i686-tools-busybox" ]]
then
  dep "i686-tools-glibc"
fi

# Add all cross-compilation toolchain packages in as build-time dependencies.
for p in \
  file m4 ncurses pkg-config-lite gmp mpfr mpc isl cloog \
  binutils gcc bc
do
  dep "i686-cross-$p"
done
dep "i686-tools-linux-headers"
