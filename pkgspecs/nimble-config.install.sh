#!/bin/bash
set -Eeo pipefail
nimble refresh

cat > /etc/profile.d/nimble.sh <<'EOF'
# /bin/bash
export PATH="$PATH:/.nimble/bin"
EOF
