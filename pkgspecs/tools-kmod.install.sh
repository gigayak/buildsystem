#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh
cd "$YAK_WORKSPACE"/kmod-*/
make install

# Per CLFS book:
#   Create symbolic links for programs that expect Module-Init-Tools:
ln -sfv kmod "/tools/$YAK_TARGET_ARCH/bin/lsmod"
for tool in depmod insmod modprobe modinfo rmmod; do
    ln -sv ../bin/kmod "/tools/$YAK_TARGET_ARCH/sbin/$tool"
done

