#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# The usual suspects: download and extract source.
dep wget
dep tar

# To build M4:
dep automake
dep autoconf
dep gcc
