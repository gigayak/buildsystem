#!/bin/bash
set -Eeo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$BUILDTOOLS/all.sh"

# Compilers.
dep go
dep gcc

# To download source.
dep git

# To make sure we trust the git server.
dep internal-ca-certificates
