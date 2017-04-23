#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
CLFS="/clfs-root"
mkdir -pv ${CLFS}
mkdir -pv ${CLFS}/{bin,boot,dev,{etc/,}opt,home,lib/firmware,mnt}
mkdir -pv ${CLFS}/{proc,media/{floppy,cdrom},run/{,shm},sbin,srv,sys}
mkdir -pv ${CLFS}/var/{lock,log,mail,spool}
mkdir -pv ${CLFS}/var/{opt,cache,lib/{misc,locate},local}
install -dv -m 0750 ${CLFS}/root
install -dv -m 1777 ${CLFS}{/var,}/tmp
# This creates a link pointing at /run from /var/run.  ../run is relative to
# ${CLFS}/var/, not to ${PWD}/.
ln -sv ../run ${CLFS}/var/run
mkdir -pv ${CLFS}/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv ${CLFS}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${CLFS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv ${CLFS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
case $YAK_TARGET_ARCH in
x86_64|amd64)
  mkdir -pv ${CLFS}/{lib64,usr/lib64,usr/local/lib64}
  ;;
esac
