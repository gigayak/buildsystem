#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To download and extract source code:
dep tar
dep wget

# For whatever reason, make mrproper requires gcc despite being nothing but
# filesystem operations.
dep gcc
