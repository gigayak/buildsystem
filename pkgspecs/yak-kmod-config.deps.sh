#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep kmod # for /bin/depmod
dep linux # for kernel modules to crunch into dependency lists
