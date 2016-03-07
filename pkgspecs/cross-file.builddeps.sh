#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To pull down sources
dep wget
dep tar

# To build sources
dep gcc
dep autoconf
dep automake
