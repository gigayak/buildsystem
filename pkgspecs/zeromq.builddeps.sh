#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

dep wget # to fetch package
dep tar # to extract package

# Development tools, to build with
dep autoconf
dep automake
dep binutils
dep bison
dep flex
dep gcc
dep gcc-c++
dep gettext
dep libtool
dep make
dep patch
dep pkgconfig

