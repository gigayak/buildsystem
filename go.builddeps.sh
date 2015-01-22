#!/bin/bash
set -Eeo pipefail
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Compilers.
echo go
echo gcc

# To download source.
echo git

# To make sure we trust the git server.
echo internal-ca-certificates
