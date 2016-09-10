#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar

dep autoconf
dep automake
dep make
dep gcc
