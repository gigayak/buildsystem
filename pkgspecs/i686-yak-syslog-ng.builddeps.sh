!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep i686-tools2-wget
dep i686-tools2-tar
dep i686-yak-gcc
dep i686-yak-pkg-config-lite
# Needed to generate `configure` script:
#dep i686-yak-debianutils
#dep i686-yak-autoconf
#dep i686-yak-automake
