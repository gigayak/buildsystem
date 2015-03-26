#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "This script builds all of Linux."
start_from="$1"
waiting=0
if [[ ! -z "$start_from" ]]
then
  waiting=1
fi

logdir="/mnt/vol_b/tmp/logs"
mkdir -pv "$logdir"

pkgs=()
pkgs+=("i686-clfs-root")
pkgs+=("i686-cross-root")
pkgs+=("i686-cross-env")
pkgs+=("i686-tools-root")
pkgs+=("i686-tools-env")
for p in \
  file linux-headers m4 \
  ncurses pkg-config-lite gmp mpfr mpc isl cloog \
  isl binutils gcc-static bc
do
  pkgs+=("i686-cross-$p")
done
pkgs+=("i686-tools-glibc")
pkgs+=("i686-cross-gcc")
for p in \
  gmp mpfr mpc isl cloog zlib binutils gcc ncurses bash bzip2 check coreutils \
  diffutils file findutils gawk gettext grep gzip make patch sed tar texinfo \
  util-linux xz bootscripts e2fsprogs kmod shadow sysvinit eudev linux grub \
  gcc-aliases bash-aliases coreutils-aliases grep-aliases file-aliases \
  sysvinit-aliases shadow-aliases linux-aliases linux-devices
do
  pkgs+=("i686-tools-$p")
done

for p in "${pkgs[@]}"
do
  if (( "$waiting" ))
  then
    if [[ "$p" == "$start_from" ]]
    then
      waiting=0
    else
      echo "Ignoring package '$p'"
      continue
    fi
  fi
  echo "Building package '$p'"
  retval=0
  "$DIR/pkg.from_name.sh" --pkg_name="$p" 2>&1 \
    | tee "$logdir/$p.log" \
    || retval=$?
  if (( "$retval" ))
  then
    echo "Building package '$p' failed with code $retval"
    exit 1
  fi
done
echo "Everything finished!  Woo-hoo!"
