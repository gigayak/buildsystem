#!/bin/bash
set -Eeo pipefail

root="$WORKSPACE/root"
tgt="$root/clfs-root/tools/$TARGET_ARCH/bin/buildsystem"
mkdir -p "$tgt"
"$BUILDSYSTEM/install_buildsystem.sh" --output_path="$tgt" >&2
tar -cz -C "$root" .
