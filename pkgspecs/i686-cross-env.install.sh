#!/bin/bash
set -Eeo pipefail

cat > /cross-tools/env.sh <<'EOF'
# /bin/bash
# Clear environment as best we can.
eval "$(env | sed -nre 's@^([^=]+)=.*$@unset \1@gp')"

# Set the few variables we care about.
# Many programs rely on these.
export HOME=/root
export TERM=screen
export PS1='\u:\w\$ '
export LC_ALL=POSIX
export PATH='/cross-tools/i686/bin:/bin:/usr/bin'

# Our scripts rely on these.
export CLFS_HOST="$(echo "$MACHTYPE" | sed -e 's/-[^-]*/-cross/')"
# From table at:
#   http://www.clfs.org/view/CLFS-3.0.0-SYSVINIT/x86/final-preps/variables.html
export CLFS_TARGET="i686-pc-linux-gnu"
export CLFS="/clfs-root"

# Disable bash command hashing, which caches name -> binary resolutions. Since
# we may rebuild a binary and then promptly use it, we don't want false positive
# cache hits.
set +h

# Default umask to prevent any oddness.
# TODO: Wouldn't this cause oddness with the whole build system if not a noop?
umask 022
EOF
