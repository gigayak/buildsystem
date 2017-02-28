#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"
dep wget
dep tar
dep make
dep autoconf
dep automake
dep gcc
dep gettext
