#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

# /bin/hostname needed
dep net-tools
