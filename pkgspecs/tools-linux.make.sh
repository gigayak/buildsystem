#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/kconfig.sh"
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=3.18.3
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.kernel.org/pub/linux/kernel/v3.x/linux-$version.tar.xz"
wget "$url"

tar -Jxf "linux-$version.tar.xz"
cd linux-*/

kconfig_init \
  ARCH=i386 \
  CROSS_COMPILE=${CLFS_TARGET}- \
  defconfig

# Save off a copy of the configuration to install to /opt/kernel.config.default
cp -v .config "$YAK_WORKSPACE/kernel.config.default"

# /dev needs to be handled by the kernel or we won't see ANY devices due to the
# lack of MAKEDEV scripts.
kconfig_set DEVTMPFS y
# HP Smart Array driver - needed for P410i on HP DL380g7.
kconfig_set SCSI_LOWLEVEL y # required for SCSI_HPSA
kconfig_set SCSI_HPSA y # SCSI driver itself
kconfig_kernel_finalize_hack \
  ARCH=i386 \
  CROSS_COMPILE=${CLFS_TARGET}-

# Build the kernel
echo "Building the kernel"
make ARCH=i386 CROSS_COMPILE=${CLFS_TARGET}-
