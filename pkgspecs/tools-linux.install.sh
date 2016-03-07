#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd "$YAK_WORKSPACE"/linux-*/

# Install kernel modules (if any are needed by .config)
make ARCH=i386 CROSS_COMPILE=${CLFS_TARGET}- \
    INSTALL_MOD_PATH=/tools/i686 modules_install

# Install firmware (if any is needed by .config)
make ARCH=i386 CROSS_COMPILE=${CLFS_TARGET}- \
    INSTALL_MOD_PATH=/tools/i686 firmware_install

# Create directory for kernel image
# TODO: Does this belong in i686-tools-root?
mkdir -pv /tools/i686/boot

# Install kernel image
#
# WARNING: do not exceed old MS-DOS 8.3 naming: longer names will explode
# the ISOLINUX bootloader.  Additionally, there seem to be heuristics about
# compression based on the filename being "vmlinuz" or "vmlinux", so it's
# probably good to avoid messing with this filename.
cp -v arch/i386/boot/bzImage /tools/i686/boot/vmlinuz

# Install map of function entry points
#
# WARNING: MS-DOS 8.3 naming may be required here.
cp -v System.map /tools/i686/boot/System.map

# Save off configuration files
cp -v .config /tools/i686/boot/kernel.config
cp -v "$YAK_WORKSPACE/kernel.config.default" /tools/i686/boot/kernel.config.default
