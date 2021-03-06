#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}
source "$(DIR)/../cleanup.sh"

make_temp_dir root

{
  mkdir -pv "$root"/{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
  mkdir -pv "$root"/{media/{floppy,cdrom},sbin,srv,var}
  install -dv -m 0750 "$root"/root
  install -dv -m 1777 "$root"/tmp "$root"/var/tmp
  mkdir -pv "$root"/usr/{,local/}{bin,include,lib,sbin,src}
  mkdir -pv "$root"/usr/{,local/}share/{color,dict,doc,info,locale,man}
  mkdir -v  "$root"/usr/{,local/}share/{misc,terminfo,zoneinfo}
  mkdir -v  "$root"/usr/libexec
  mkdir -pv "$root"/usr/{,local/}share/man/man{1..8}
  mkdir -v "$root"/var/{log,mail,spool}
  ln -sv /run "$root"/var/run
  ln -sv /run/lock "$root"/var/lock
  mkdir -pv "$root"/var/{opt,cache,lib/{color,misc,locate},local}
  mkdir -pv "$root"/dev
  mkdir -pv "$root"/proc
  mkdir -pv "$root"/run/{lock,utmp,udev}
  mkdir -pv "$root"/sys
  case $YAK_TARGET_ARCH in
    x86_64|amd64)
      echo "Creating 64-bit specific directories."
      mkdir -pv "$root"{,/usr,/usr/local,/var}/lib64
  esac
} >&2

tar -cz -C "$root" .
