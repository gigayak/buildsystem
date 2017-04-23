#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.

cd "$YAK_WORKSPACE"/linux-*/

# Install kernel modules (if any are needed by .config)
make modules_install

# Install firmware (if any is needed by .config)
make firmware_install

# Install kernel image
#
# WARNING: do not exceed old MS-DOS 8.3 naming: longer names will explode
# the ISOLINUX bootloader.  Additionally, there seem to be heuristics about
# compression based on the filename being "vmlinuz" or "vmlinux", so it's
# probably good to avoid messing with this filename.
# TODO: arch/i386 originally - does using fully-specified ARCH cause problems?
cp -v "arch/$YAK_TARGET_ARCH/boot/bzImage" /boot/vmlinuz

# Install map of function entry points
#
# WARNING: MS-DOS 8.3 naming may be required here.
cp -v System.map /boot/System.map

# Save off configuration files
cp -v .config /boot/kernel.config
cp -v "$YAK_WORKSPACE/kernel.config.default" /boot/kernel.config.default
