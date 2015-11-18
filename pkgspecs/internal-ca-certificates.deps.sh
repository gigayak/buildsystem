#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# Ensure base CA certs are installed.
dep ca-certificates

# Aaaand everything will be fubar if dynamic CA certs are disabled.  Default
# is disabled, so this massive hack of an RPM will enable them via alternatives.
dep enable-dynamic-ca-certificates
