#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
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
# ACPI is required for using SD cards with ACPI.  Also for many other things...
# (It was already set by default... this is insurance.)
kconfig_set ACPI y
# Booting from an SD card requires MMC.
#
# MMC enables the overall subsystem.  MMC_BLOCK enables device block drivers
# on MMC/SD devices.
#
# The other options are all for MMC sub-drivers.
# I may have used a shell script to scrape these:
#   curl http://cateee.net/lkddb/web-lkddb/MMC.html \
#     | sed -nre 's@^.*CONFIG_(MMC_[A-Za-z0-9_-]+).*$@\1@gp' \
#     | sort | uniq | tr '\n' ' ' | sed -re 's@$@\n@g'
# TODO: Support kconfig_set_recursively to allow all children to be set as well.
# In this case, setting CONFIG_MMC and all of its children to y would be fine.
#
# Commented out these options because they have unmet dependencies:
#   MMC_AT91 MMC_AT91RM9200 MMC_ATMELMCI MMC_AU1X MMC_DAVINCI MMC_DW MMC_IMX
#   MMC_JZ4740 MMC_MSM MMC_MSM7X00A MMC_MVSDIO MMC_MXC MMC_MXS MMC_OMAP
#   MMC_OMAP_HS MMC_PXA MMC_S3C MMC_SDHCI_CNS3XXX MMC_SDHCI_DOVE
#   MMC_SDHCI_ESDHC_IMX MMC_SDHCI_OF MMC_SDHCI_OF_ESDHX MMC_SDHCI_OF_HLWD
#   MMC_SDHCI_PXA MMC_SDHCI_PXAV2 MMC_SDHCI_PXAV3 MMC_SDHCI_S3C MMC_SDHCI_SPEAR
#   MMC_SDHCI_TEGRA MMC_SDHI MMC_SH_MMCIF MMC_SPI MMC_TMIO
#
# Additionally, http://askubuntu.com/a/277626 tipped me off to a Texas
# Instruments driver existing, which wasn't listed on cateee.net for some
# reason.  Included TIFM_CORE and TIFM_7XX1 thanks to the documentation on
# MMC_TIFM_SD implying it may be needed...
#
# SDIO_UART enables GPS-type devices, which will likely prove handy eventually.
for flag in \
  MMC MMC_BLOCK \
  MMC_CB710 MMC_RICOH_MMC MMC_SDHCI MMC_SDHCI_ACPI MMC_SDHCI_PCI \
  MMC_SDHCI_PLTFM MMC_SDRICOH_CS MMC_USHC MMC_VIA_SDMMC MMC_VUB300 MMC_WBSD \
  MMC_TIFM_SD TIFM_CORE TIFM_7XX1 \
  SDIO_UART
do
  kconfig_set "$flag" y
done

# And should you plug your SD card reader or flash drive into a USB3 port,
# perhaps it should be recognized by the kernel...
kconfig_set USB y
kconfig_set USB_UHCI_HCD y
kconfig_set USB_OHCI_HCD y
kconfig_set USB_EHCI_HCD y
kconfig_set USB_XHCI_HCD y

# Other USB configuration...
kconfig_set INPUT y
kconfig_set INPUT_KEYBOARD y
kconfig_set INPUT_MOUSE y
kconfig_set INPUT_JOYSTICK y
kconfig_set INPUT_JOYDEV y
kconfig_set INPUT_EVDEV y
kconfig_set USB_HID y
kconfig_set USB_HIDDEV y
kconfig_set HID y
kconfig_set HID_GENERIC y
kconfig_set HID_APPLE m
kconfig_set HID_WACOM m
kconfig_set HID_LOGITECH m
kconfig_set HID_SENSOR_HUB m
kconfig_set INTEL_ISH_HID m
kconfig_set USB_XPAD m


# Common network drivers.
kconfig_set ETHERNET y
# Realtek:
kconfig_set NET_VENDOR_REALTEK y
kconfig_set R8169 m
kconfig_set 8139TOO m
kconfig_set 8139CP m
kconfig_set MII m # used by R8169 in working Ubuntu deployment...

# CPU-specific flags
kconfig_set HWMON m
# AMD-specific stuff:
# TODO: x86-only?
kconfig_set HSA_AMD m
kconfig_set RADEON m
kconfig_set SENSORS_K10TEMP m

# Enable everything we can possibly enable from the sound Kconfigs...
while read -r config_name
do
  kconfig_set "$config_name" m
done < <(find sound -iname Kconfig \
  | xargs -I{} grep -E -e '^config SND' {} \
  | sed -r -e 's@^config @@g' \
  | sort \
  | uniq \
)

kconfig_kernel_finalize_hack

# Build the kernel
echo "Building the kernel"
make -j 8
