#!/bin/bash
set -Eeo pipefail

root="$YAK_WORKSPACE/root"
tgt="$root/usr/bin/buildsystem"
mkdir -p "$tgt"
"$YAK_BUILDSYSTEM/install_buildsystem.sh" --output_path="$tgt" >&2
tar -cz -C "$root" .
