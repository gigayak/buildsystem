#!/bin/bash
set -Eeo pipefail

# Need wget and tar to download and extract source.
echo wget
echo tar

# Some packages require a native GCC to build utilities which are then used
# during the package build process.
echo gcc
echo gcc-c++

# binutils requires texinfo
if [[ "$PKG_NAME" == "i686-tools-binutils" ]]
then
  echo texinfo
fi

# as does e2fsprogs
if [[ "$PKG_NAME" == "i686-tools-e2fsprogs" ]]
then
  echo texinfo
fi

# Add all cross-compilation toolchain packages in as build-time dependencies.
for p in \
  file linux-headers m4 ncurses pkg-config-lite gmp mpfr mpc isl cloog \
  binutils gcc
do
  echo "i686-cross-$p"
done