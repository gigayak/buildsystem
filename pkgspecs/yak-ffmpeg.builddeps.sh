#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar
dep automake
dep autoconf
dep make
dep yasm
dep gcc
dep pkg-config-lite
dep diffutils
