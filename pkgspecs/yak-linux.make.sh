#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/kconfig.sh"

cd "$YAK_WORKSPACE"
version=3.18.3
echo "$version" > "$YAK_WORKSPACE/version"
url="https://www.kernel.org/pub/linux/kernel/v3.x/linux-$version.tar.xz"
wget --no-check-certificate "$url"
tar -xf *.tar.*

cd linux-*/

kconfig_init defconfig

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
# Bridges are required for LXC.
kconfig_set NET y
kconfig_set BRIDGE y

kconfig_kernel_finalize_hack

# Build the kernel
echo "Building the kernel"
make
