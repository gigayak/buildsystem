#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep wget
dep tar

dep gcc
dep pkg-config-lite
dep bison
dep make
dep m4
