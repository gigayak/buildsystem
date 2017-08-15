#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar
dep autoconf
dep automake
dep libtool
dep make
dep gcc
dep pkg-config-lite
