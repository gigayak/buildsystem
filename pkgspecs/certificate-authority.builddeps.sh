#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"
dep curl
dep git
dep internal-ca-certificates
