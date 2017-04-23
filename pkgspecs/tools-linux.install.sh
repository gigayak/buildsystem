#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh
cd "$YAK_WORKSPACE"/linux-*/

# Install kernel modules (if any are needed by .config)
# TODO: ARCH=i386 originally - does using fully-specified ARCH cause problems?
make ARCH="$YAK_TARGET_ARCH" CROSS_COMPILE=${CLFS_TARGET}- \
    INSTALL_MOD_PATH="/tools/$YAK_TARGET_ARCH" modules_install

# Install firmware (if any is needed by .config)
# TODO: ARCH=i386 originally - does using fully-specified ARCH cause problems?
make ARCH="$YAK_TARGET_ARCH" CROSS_COMPILE=${CLFS_TARGET}- \
    INSTALL_MOD_PATH="/tools/$YAK_TARGET_ARCH" firmware_install

# Create directory for kernel image
# TODO: Does this belong in tools-root?
mkdir -pv "/tools/${YAK_TARGET_ARCH}/boot"

# Install kernel image
#
# WARNING: do not exceed old MS-DOS 8.3 naming: longer names will explode
# the ISOLINUX bootloader.  Additionally, there seem to be heuristics about
# compression based on the filename being "vmlinuz" or "vmlinux", so it's
# probably good to avoid messing with this filename.
# TODO: arch/i386 originally - does using fully-specified ARCH cause problems?
cp -v "arch/${YAK_TARGET_ARCH}/boot/bzImage" \
  "/tools/${YAK_TARGET_ARCH}/boot/vmlinuz"

# Install map of function entry points
#
# WARNING: MS-DOS 8.3 naming may be required here.
cp -v System.map "/tools/${YAK_TARGET_ARCH}/boot/System.map"

# Save off configuration files
cp -v .config "/tools/$YAK_TARGET_ARCH/boot/kernel.config"
cp -v "$YAK_WORKSPACE/kernel.config.default" \
  "/tools/$YAK_TARGET_ARCH/boot/kernel.config.default"
