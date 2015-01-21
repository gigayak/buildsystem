#!/bin/bash
set -Eeo pipefail

# Ensure base CA certs are installed.
echo ca-certificates

# Aaaand everything will be fubar if dynamic CA certs are disabled.  Default
# is disabled, so this massive hack of an RPM will enable them via alternatives.
echo enable-dynamic-ca-certificates
