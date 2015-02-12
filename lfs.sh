#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "This script builds all of Linux."

pkgs=()
pkgs+=("i686-clfs-root")
pkgs+=("i686-cross-root")
pkgs+=("i686-cross-env")
pkgs+=("i686-tools-root")
for p in \
  file linux-headers m4 \
  ncurses pkg-config-lite gmp mpfr mpc isl cloog \
  isl binutils gcc-static
do
  pkgs+=("i686-cross-$p")
done
pkgs+=("i686-tools-glibc")
pkgs+=("i686-cross-gcc")

for p in "${pkgs[@]}"
do
  echo "Building package '$p'"
  retval=0
  "$DIR/pkg.from_name.sh" --pkg_name="$p" || retval=$?
  if (( "$retval" ))
  then
    echo "Building package '$p' failed with code $retval"
    exit 1
  fi
done
echo "Everything finished!  Woo-hoo!"