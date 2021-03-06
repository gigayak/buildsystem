#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source "$YAK_BUILDTOOLS/kconfig.sh"
source /tools/env.sh

cd "$YAK_WORKSPACE"
version=4.7
echo "$version" > "$YAK_WORKSPACE/version"
major_version="$(echo "$version" | sed -nre 's@^([0-9]+\.).*$@v\1x@gp')"
urldir="https://www.kernel.org/pub/linux/kernel/$major_version"
url="$urldir/linux-$version.tar.xz"
wget "$url"

tar -Jxf "linux-$version.tar.xz"
cd linux-*/

# TODO: ARCH=i386 originally - does using fully-specified ARCH cause problems?
kconfig_init \
  ARCH="$YAK_TARGET_ARCH" \
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
# KVM is required to build a new copy of this OS, as it uses KVM-accelerated
# qemu in the build process.
# The following kernel flags came from:
#   www.linux-kvm.org/page/Tuning_Kernel
#  HIGH_RES_TIMER \
#  VIRTIO_SERIAL \
#  PARAVIRT_GUEST \
#  KVM_CLOCK \
#  KVM_GUEST \
#  PARAVIRT \
#  MEMORY_HOTPLUG \
#  MEMORY_HOTREMOVE \
#  ACPIPHP \
#  PCI_HOTPLUG \
for flag in \
  VIRTUALIZATION \
  KVM \
  KVM_INTEL \
  KVM_AMD \
  VHOST_NET \
  HPET \
  COMPACTION \
  MIGRATION \
  KSM \
  TRANSPARENT_HUGEPAGE \
  CGROUPS \
  VIRTIO \
  VIRTIO_NET \
  VIRTIO_BLK \
  VIRTIO_PCI \
  VIRTIO_BALLOON \
  VIRTIO_CONSOLE \
  HW_RANDOM_VIRTIO \
  PCI_MSI
do
  kconfig_set "$flag" y
done

# TODO: ARCH=i386 originally - does using fully-specified ARCH cause problems?
kconfig_kernel_finalize_hack \
  ARCH="$YAK_TARGET_ARCH" \
  CROSS_COMPILE=${CLFS_TARGET}-

# Build the kernel
echo "Building the kernel"
make \
  ARCH="$YAK_TARGET_ARCH" \
  CROSS_COMPILE=${CLFS_TARGET}-
