#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download required packages into initrd chroot.
dep buildsystem

# To package everything up.
dep gzip
dep tar
dep cpio
