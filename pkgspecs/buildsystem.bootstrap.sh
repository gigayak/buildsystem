#!/bin/bash
set -Eeo pipefail

root="$WORKSPACE/root"
tgt="$root/usr/bin/buildsystem"
mkdir -p "$tgt"
"$BUILDSYSTEM/install_buildsystem.sh" --output_path="$tgt" >&2
tar -cz -C "$root" .
