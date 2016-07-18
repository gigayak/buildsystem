#!/bin/bash
set -Eeo pipefail
DIR(){(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)}

# Backwards build: build the yak ca-certificates first, and then copy its data
# into the locations expected by tools.
source_root="$YAK_WORKSPACE/source_root"
mkdir -p "$source_root"
"$YAK_BUILDSYSTEM/install_pkg.sh" \
  --install_root="$source_root" \
  --target_distribution="yak" \
  --pkg_name="ca-certificates" \
  >&2

target_root="$YAK_WORKSPACE/target_root"
mkdir -p "$target_root"
tools_root="clfs-root/tools/$YAK_TARGET_ARCH"
mkdir -p "$target_root/$tools_root/etc/ssl"
cp -r {"$source_root","$target_root/$tools_root"}"/etc/ssl/certs"
mkdir -p "$target_root/$tools_root/usr/share"
cp -r {"$source_root","$target_root/$tools_root"}"/usr/share/ca-certificates"

# Correct symlinks
while read -r link_path
do
  link_target="/tools/${YAK_TARGET_ARCH}$(readlink "$link_path")"
  rm "$link_path"
  ln -s "$link_target" "$link_path"
done < <(find "$target_root" -type l)

tar -cz -C "$target_root" .
