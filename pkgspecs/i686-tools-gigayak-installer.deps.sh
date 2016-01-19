#!/bin/bash
set -Eeuo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-tools-env
dep i686-tools-bash # to interpret script
dep i686-tools-findutils # to locate disk to install to
dep i686-tools-util-linux # blkid
dep i686-tools-e2fsprogs # mkfs.ext4
dep i686-tools-rsync # to copy files across
dep i686-tools-grub # to install bootloader
