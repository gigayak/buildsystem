#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Starting stage 3 bootstrap"
echo "This uses i686-tools-buildsystem to build all native packages."

if [[ ! -d "/var/www/html/tgzrepo" ]]
then
  echo "HACK TIME: creating repository directory"
  mkdir -pv "/var/www/html/tgzrepo"
fi
if grep ' /tmp ' /proc/mounts > /dev/null 2>&1
then
  echo "HACK TIME: unmounting /tmp, it isn't big enough"
  umount /tmp
fi

start_at="$@"

pkgs=()
pkgs+=("i686-tools3-tcl")
pkgs+=("i686-tools3-expect")
pkgs+=("i686-tools3-dejagnu")
pkgs+=("i686-tools3-perl")
pkgs+=("i686-tools3-texinfo")
pkgs+=("i686-tools3-gdb")
pkgs+=("i686-yak-linux-headers")
pkgs+=("i686-yak-man-pages")
pkgs+=("i686-yak-glibc")
pkgs+=("i686-tools3-gcc")
pkgs+=("i686-yak-m4")
pkgs+=("i686-yak-gmp")
pkgs+=("i686-yak-mpfr")
pkgs+=("i686-yak-mpc")
pkgs+=("i686-yak-isl")
pkgs+=("i686-yak-cloog")
pkgs+=("i686-yak-zlib")
pkgs+=("i686-yak-flex")
pkgs+=("i686-yak-bison")
pkgs+=("i686-yak-binutils")
pkgs+=("i686-yak-gcc")
pkgs+=("i686-yak-sed")
pkgs+=("i686-yak-pkg-config-lite")
pkgs+=("i686-yak-ncurses")
pkgs+=("i686-yak-shadow")
pkgs+=("i686-yak-util-linux")
pkgs+=("i686-yak-autoconf")
pkgs+=("i686-yak-automake")
pkgs+=("i686-yak-libtool")
pkgs+=("i686-yak-gettext")
pkgs+=("i686-yak-procps-ng")
pkgs+=("i686-yak-e2fsprogs")
pkgs+=("i686-yak-coreutils")
pkgs+=("i686-yak-iana-etc")
pkgs+=("i686-yak-iproute2")
pkgs+=("i686-yak-bzip2")
pkgs+=("i686-yak-gdbm")
pkgs+=("i686-yak-perl")
pkgs+=("i686-yak-readline")
pkgs+=("i686-yak-bash")
pkgs+=("i686-yak-bc")
pkgs+=("i686-yak-diffutils")
pkgs+=("i686-yak-file")
pkgs+=("i686-yak-gawk")
pkgs+=("i686-yak-findutils")
pkgs+=("i686-yak-grep")
pkgs+=("i686-yak-groff")
pkgs+=("i686-yak-less")
pkgs+=("i686-yak-gzip")
pkgs+=("i686-yak-iputils")
pkgs+=("i686-yak-kbd")
pkgs+=("i686-yak-libpipeline")
pkgs+=("i686-yak-man")
pkgs+=("i686-yak-make")

build="$DIR/pkg.from_name.sh"
for p in "${pkgs[@]}"
do
  if [[ ! -z "$start_at" ]]
  then
    if [[ \
      "$p" == "$start_at" \
      || "$p" == "i686-tools3-$start_at" \
      || "$p" == "i686-yak-$start_at" \
    ]]
    then
      start_at=""
    else
      continue
    fi
  fi
  echo "$(basename "$0"): building package '$p'" >&2
  retval=0
  "$build" --pkg_name="$p" || retval=$?
  if (( "$retval" ))
  then
    echo "$(basename "$0"): failed to build package '$p' with code $retval" >&2
    exit 1
  fi
  echo "$(basename "$0"): successfully built package '$p'" >&2
done
