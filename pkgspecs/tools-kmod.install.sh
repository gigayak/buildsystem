#!/bin/bash
set -Eeo pipefail
source /tools/env.sh
cd /root/kmod-*/
make install

# Per CLFS book:
#   Create symbolic links for programs that expect Module-Init-Tools:
ln -sfv kmod /tools/i686/bin/lsmod
for tool in depmod insmod modprobe modinfo rmmod; do
    ln -sv ../bin/kmod /tools/i686/sbin/${tool}
done

