#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/linux-*/

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
cp -v arch/i386/boot/bzImage /tools/i686/boot/vmlinuz-clfs-3.14.21

# Install map of function entry points
cp -v System.map /tools/i686/boot/System.map-3.14.21

# Save off configuration files
cp -v .config /tools/i686/boot/kernel.config-3.14.21
cp -v /root/kernel.config.default /tools/i686/boot/kernel.config-3.14.21.default
