#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar
dep automake
dep autoconf
dep make
dep gcc
