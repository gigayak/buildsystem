#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/*-*/
cp "cgroupfs-mount" "/usr/sbin/"
cp "cgroupfs-umount" "/usr/sbin"
cp "cgroupfs-mount.8" "/usr/share/man/man8/"
cp "debian/cgroupfs-mount.init" "/etc/rc.d/init.d/cgroupfs-mount"
ln -sv "../init.d/cgroupfs-mount" "/etc/rc.d/rc3.d/cgroupfs-mount"
