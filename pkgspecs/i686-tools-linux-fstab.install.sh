#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

# Per CLFS book:
#   The /etc/fstab file is used by some programs to determine where file systems
#   are to be mounted by default, which must be checked, and in which order.
#   Create a new file systems table like this:
cat > ${CLFS}/etc/fstab << "EOF"
# file system  mount-point  type   options          dump  fsck
#                                                         order
/dev/sda1      /            ext2   defaults         1     1
/dev/sda2      swap         swap   pri=1            0     0
devpts         /dev/pts     devpts gid=5,mode=620   0     0
shm            /dev/shm     tmpfs  defaults         0     0
none           /proc        proc   defaults         0     0
EOF
# PS: I added /proc myself so that dhclient would work.  Without proc, it barfs:
#   Error opening '/proc/net/dev' to list interfaces
#   Can't get list of interfaces.
# Instructions were from:
#   http://www.microhowto.info/troubleshooting/mounting_proc.html
# TODO: Is the first token in the /proc mount ("none") okay?
