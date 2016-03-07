#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# This initializes the mountpoints that are needed to boot.  This allows us
# to boot even with the rootfs mounted read-only - such as in the install
# CD use case (or recovery attempt use case).
mkdir -pv "$CLFS"/{proc,sys,run{,/lock},tmp}

# We likely have /proc and /sys mounted - so let's explicitly tell the
# packager to pick them up.
cat >> "$YAK_WORKSPACE/extra_installed_paths" <<EOF
$CLFS/proc
$CLFS/sys
$CLFS/tmp
EOF
