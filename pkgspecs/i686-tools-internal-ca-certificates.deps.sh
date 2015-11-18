#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Gonna need our environment.
dep i686-tools-root
dep i686-tools-env

# Gonna need gnutls.
dep i686-tools-gnutls
