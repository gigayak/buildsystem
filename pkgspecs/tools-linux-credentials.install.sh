#!/bin/bash
set -Eeo pipefail
source /tools/env.sh

cat > ${CLFS}/etc/passwd <<EOF
root::0:0:root:/tools/${YAK_TARGET_ARCH}/root:/bin/bash
bin:x:1:1:/bin:/bin/false
daemon:x:2:6:/sbin:/bin/false
nobody:x:65534:65533:Unprivileged User:/dev/null:/bin/false
EOF

cat > ${CLFS}/etc/group <<EOF
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:5:
tape:x:4:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
mail:x:30:
wheel:x:39:
nogroup:x:65533:
EOF
