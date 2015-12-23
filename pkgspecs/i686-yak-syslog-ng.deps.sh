#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep i686-yak-glibc
dep i686-yak-eventlog
dep i686-yak-glib
dep i686-yak-pcre
dep i686-yak-openssl
