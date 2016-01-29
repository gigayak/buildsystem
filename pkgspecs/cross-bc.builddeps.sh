#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# To download and extract source:
dep wget
dep tar

# To build everything:
dep gcc
dep flex
