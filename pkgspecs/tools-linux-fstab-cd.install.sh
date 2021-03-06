#!/bin/bash
set -Eeo pipefail
# This file is derivative of the LFS and CLFS books.  Additional licenses apply
# to this file.  Please see LICENSE.md for details.
source /tools/env.sh

# Per CLFS book:
#   The /etc/fstab file is used by some programs to determine where file systems
#   are to be mounted by default, which must be checked, and in which order.
#   Create a new file systems table like this:
cat > ${CLFS}/etc/fstab << "EOF"
# file system  mount-point  type   options          dump  fsck
#                                                         order
/dev/sr0       /            udf,iso9660 defaults    0     0
devpts         /dev/pts     devpts gid=5,mode=620   0     0
shm            /dev/shm     tmpfs  defaults         0     0
tmpfs          /tmp         tmpfs  defaults         0     0
none           /proc        proc   defaults         0     0
EOF
# PS: I added /proc myself so that dhclient would work.  Without proc, it barfs:
#   Error opening '/proc/net/dev' to list interfaces
#   Can't get list of interfaces.
# Instructions were from:
#   http://www.microhowto.info/troubleshooting/mounting_proc.html
# TODO: Is the first token in the /proc mount ("none") okay?
