#!/bin/bash
set -Eeo pipefail

cd /root/linux-*/

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
cp -v arch/i386/boot/bzImage /boot/vmlinuz

# Install map of function entry points
#
# WARNING: MS-DOS 8.3 naming may be required here.
cp -v System.map /boot/System.map

# Save off configuration files
cp -v .config /boot/kernel.config
cp -v /root/kernel.config.default /boot/kernel.config.default
