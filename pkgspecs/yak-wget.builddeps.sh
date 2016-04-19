#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# TODO: Refactor this silliness out as a function in $YAK_BUILDTOOLS.
"$YAK_BUILDSYSTEM/install_pkg.sh" \
  --target_architecture="$YAK_TARGET_ARCH" \
  --target_distribution="yak" \
  --install_root="/" \
  --pkg_name="wget" \
  --no_build \
|| "$YAK_BUILDSYSTEM/install_pkg.sh" \
  --target_architecture="$YAK_TARGET_ARCH" \
  --target_distribution="tools2" \
  --install_root="/" \
  --pkg_name="wget" \
  --no_build \
|| exit 1

dep --arch="$YAK_TARGET_ARCH" --distro=yak pkg-config-lite
dep --arch="$YAK_TARGET_ARCH" --distro=yak gcc
