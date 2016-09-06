#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/kconfig.sh"

cd "$YAK_WORKSPACE"
version=4.7
echo "$version" > "$YAK_WORKSPACE/version"
major_version="$(echo "$version" | sed -nre 's@^([0-9]+\.).*$@v\1x@gp')"
urldir="https://www.kernel.org/pub/linux/kernel/$major_version"
url="$urldir/linux-$version.tar.xz"
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
# And virtual ethernet pairs, to connect to those bridges:
kconfig_set VETH y
# VLANs are used when VLAN networking is used in place of bridged networking:
kconfig_set MACVLAN y
kconfig_set VLAN_8021Q y
# /dev/pts needs to be multiply-instantiated for LXC.
# OBSOLETE as of this commit:
# https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/tty/Kconfig?id=eedf265aa003b4781de24cfed40a655a664457e6
#kconfig_set DEVPTS_MULTIPLE_INSTANCES y
# cgroups and namespacing are required for LXC.
for flag in \
  NAMESPACES PID_NS NET_NS USER_NS UTS_NS IPC_NS \
  CGROUPS CGROUP_DEVICE CPUSETS CGROUP_FREEZER \
  CGROUP_SCHED FAIR_GROUP_SCHED BLK_CGROUP CFQ_GROUP_IOSCHED \
  CGROUP_CPUACCT
do
  # TODO: Likely not in current kernel version, uncomment when rebuilding 4.x?:
  #CGROUP_MEM_RES_CTLR CGROUP_MEM_RES_CTLR_SWAP \
  kconfig_set "$flag" y
done
# qemu requires /dev/net/tun, provided by TUN:
kconfig_set TUN y

kconfig_kernel_finalize_hack

# Build the kernel
echo "Building the kernel"
make
