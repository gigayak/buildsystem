#!/bin/bash
set -Eeo pipefail
cd "$YAK_WORKSPACE"/bootscripts-cross-lfs-*/
make DESTDIR="/tools/${YAK_TARGET_ARCH}" install-minimal

cat > "/tools/${YAK_TARGET_ARCH}/etc/sysconfig/clock" <<'EOF'
# Whether or not hardware realtime clock is set to UTC timezone.
UTC=1
EOF
