#!/bin/bash
set -Eeuo pipefail
echo i686-tools-env
echo i686-tools-bash # to interpret script
echo i686-tools-findutils # to locate disk to install to
echo i686-tools-util-linux # blkid
echo i686-tools-e2fsprogs # mkfs.ext4
echo i686-tools-rsync # to copy files across
echo i686-tools-grub # to install bootloader
