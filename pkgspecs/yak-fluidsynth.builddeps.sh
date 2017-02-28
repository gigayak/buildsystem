#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar
dep make
dep automake
dep autoconf
dep gcc
dep pkg-config-lite
