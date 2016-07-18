#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep --arch="$YAK_HOST_ARCH" --distro=tools2 wget
dep --arch="$YAK_HOST_ARCH" --distro=tools2 ca-certificates
