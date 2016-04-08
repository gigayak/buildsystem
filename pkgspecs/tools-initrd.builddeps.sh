#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To download required packages into initrd chroot.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" buildsystem

# To package everything up.
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" gzip
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" tar
dep --arch="$YAK_HOST_ARCH" --distro="$YAK_HOST_OS" cpio
