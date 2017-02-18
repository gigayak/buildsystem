#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep bash # to interpret script
dep findutils # to locate disk to install to
dep util-linux # blkid
dep e2fsprogs # mkfs.ext4
dep syslinux # to install bootloader
dep buildsystem # to install packages
