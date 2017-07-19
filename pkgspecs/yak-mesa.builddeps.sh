#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar
dep gcc
dep make
dep automake
dep autoconf
dep pkg-config-lite
dep llvm
