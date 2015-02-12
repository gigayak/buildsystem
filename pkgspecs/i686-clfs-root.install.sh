#!/bin/bash
set -Eeo pipefail
CLFS="/clfs-root"
mkdir -pv ${CLFS}
mkdir -pv ${CLFS}/{bin,boot,dev,{etc/,}opt,home,lib/firmware,mnt}
mkdir -pv ${CLFS}/{proc,media/{floppy,cdrom},run/{,shm},sbin,srv,sys}
mkdir -pv ${CLFS}/var/{lock,log,mail,spool}
mkdir -pv ${CLFS}/var/{opt,cache,lib/{misc,locate},local}
install -dv -m 0750 ${CLFS}/root
install -dv -m 1777 ${CLFS}{/var,}/tmp
# TODO: Is this symlink needed?  $PWD is not listed in the book here.
#   http://www.clfs.org/view/CLFS-3.0.0-SYSVINIT/x86/boot/creatingdirs.html
#ln -sv ../run ${CLFS}/var/run
mkdir -pv ${CLFS}/usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv ${CLFS}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${CLFS}/usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv ${CLFS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}
