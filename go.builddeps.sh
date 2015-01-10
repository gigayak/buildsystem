#!/bin/bash
set -Eeo pipefail
set -x
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Compiler.
echo go

# To extract source.
echo tar
