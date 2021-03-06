#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep wget # to fetch package
dep tar # to extract package

dep go14 # used to build go >= 1.5

# Development tools, to build with
dep autoconf
dep automake
dep binutils
dep bison
dep flex
dep gcc
dep gettext
dep libtool
dep make
dep patch
dep pkg-config-lite
