#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep sed
dep wget
dep tar

dep autoconf
dep automake
dep make
#dep gcc # required as dep for libgcc
