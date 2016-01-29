#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download from source.
dep git

# To ensure trust of git server.
dep enable-dynamic-ca-certificates
dep internal-ca-certificates
