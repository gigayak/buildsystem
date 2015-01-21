#!/bin/bash
set -Eeo pipefail

cat > /etc/container.mounts <<EOF
ca /opt/ca
EOF
