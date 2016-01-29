#!/bin/bash
set -Eeuo pipefail
source "$BUILDTOOLS/all.sh"
dep --arch="$TARGET_ARCH" --distro=tools env
dep --arch="$TARGET_ARCH" --distro=tools bash # to interpret script
dep --arch="$TARGET_ARCH" --distro=tools findutils # to locate disk to install to
dep --arch="$TARGET_ARCH" --distro=tools util-linux # blkid
dep --arch="$TARGET_ARCH" --distro=tools e2fsprogs # mkfs.ext4
dep --arch="$TARGET_ARCH" --distro=tools rsync # to copy files across
dep --arch="$TARGET_ARCH" --distro=tools grub # to install bootloader
