#!/bin/bash
set -Eeo pipefail
cat > /etc/os-release <<'EOF'
NAME="Gigayak Linux"
ID=yak
ID_LIKE=yak
PRETTY_NAME="Gigayak Linux"
ANSI_COLOR="0;36"
HOME_URL="http://linux.gigayak.com/"
SUPPORT_URL="http://linux.gigayak.com/"
BUG_REPORT_URL="http://linux.gigayak.com/"
EOF
# TODO: Add support / bug report URLs.
