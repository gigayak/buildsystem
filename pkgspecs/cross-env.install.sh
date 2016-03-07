#!/bin/bash
set -Eeo pipefail

cat > /cross-tools/env.sh <<EOF
# /bin/bash
# Clear environment as best we can.
# Avoid clearing out build environment explicitly populated by pkg.sh.
eval "\$(env \\
  | sed -nre 's@^([^=]+)=.*\$@unset \\1@gp' \\
  | grep -vE '^unset YAK_')"

# Set the few variables we care about.
# Many programs rely on these.
export HOME=/root
export TERM=screen
export PS1='\\u:\\w\\\$ '
export LC_ALL=POSIX
export PATH='/cross-tools/${YAK_TARGET_ARCH}/bin:/bin:/usr/bin'
unset CFLAGS
unset CXXFLAGS

# Our scripts rely on these.
export CLFS_HOST="\$(echo "\$MACHTYPE" | sed -e 's/-[^-]*/-cross/')"
#export CLFS_HOST="\$(uname -m)-cross-\$(echo "\$MACHTYPE" \
#  | sed -re 's@^[^-]*-[^-]*-(.*)\$@\\1@g')"
# From table at:
#   http://www.clfs.org/view/CLFS-3.0.0-SYSVINIT/x86/final-preps/variables.html
export CLFS_TARGET="${YAK_TARGET_ARCH}-pc-linux-gnu"
export CLFS="/clfs-root"
export YAK_TARGET_ARCH='${YAK_TARGET_ARCH}'

# Disable bash command hashing, which caches name -> binary resolutions. Since
# we may rebuild a binary and then promptly use it, we don't want false positive
# cache hits.
set +h

# Default umask to prevent any oddness.
# TODO: Wouldn't this cause oddness with the whole build system if not a noop?
umask 022
EOF
