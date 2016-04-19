#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep autoconf
dep automake
dep gcc
