#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep gcc
dep make
dep automake
dep autoconf
dep wget
dep tar
