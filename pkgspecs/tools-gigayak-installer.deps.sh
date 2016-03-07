#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_TARGET_ARCH" --distro=tools env
dep --arch="$YAK_TARGET_ARCH" --distro=tools bash # to interpret script
dep --arch="$YAK_TARGET_ARCH" --distro=tools findutils # to locate disk to install to
dep --arch="$YAK_TARGET_ARCH" --distro=tools util-linux # blkid
dep --arch="$YAK_TARGET_ARCH" --distro=tools e2fsprogs # mkfs.ext4
dep --arch="$YAK_TARGET_ARCH" --distro=tools rsync # to copy files across
dep --arch="$YAK_TARGET_ARCH" --distro=tools grub # to install bootloader
