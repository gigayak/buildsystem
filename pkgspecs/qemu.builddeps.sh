#!/bin/bash
set -Eeo pipefail
source "$YAK_BUILDTOOLS/all.sh"

# To get and extract the source.
dep wget
dep tar

# To build the source.
dep libtool
dep gcc
dep automake
dep autoconf
dep make
dep python
dep pkg-config-lite
dep flex
dep bison
dep diffutils
