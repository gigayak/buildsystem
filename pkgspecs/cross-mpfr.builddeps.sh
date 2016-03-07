#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# Download/extract
dep wget
dep tar

# Build
dep gcc
