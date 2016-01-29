#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cp /root/initrd.igz "$CLFS/tools/i686/boot/initrd.igz"
