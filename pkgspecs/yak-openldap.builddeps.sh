#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar
dep gcc
dep automake
dep autoconf
dep make
dep groff # soelim and friends