#!/bin/bash
set -Eeo pipefail
cd /root/bootscripts-cross-lfs-*/
make DESTDIR=/tools/i686 install-minimal

cat > /tools/i686/etc/sysconfig/clock <<'EOF'
# Whether or not hardware realtime clock is set to UTC timezone.
UTC=1
EOF
