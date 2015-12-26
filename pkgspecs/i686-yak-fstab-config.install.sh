#!/bin/bash
set -Eeo pipefail

# TODO: deprecate this whole package and generate fstab configurations.
# fstab depends on hardware installed even if the partition scheme is static,
# so packaging this configuration is a little silly.

cat > /etc/fstab <<'EOF'
# file system  mount-point  type   options          dump  fsck
#                                                         order

/dev/[xxx]     /            [fff]  defaults         1     1
/dev/[yyy]     swap         swap   pri=1            0     0
devpts         /dev/pts     devpts gid=5,mode=620   0     0
shm            /dev/shm     tmpfs  defaults         0     0
EOF
