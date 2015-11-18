#!/bin/bash
set -Eeo pipefail
source "$BUILDTOOLS/all.sh"

dep wget # to fetch package
dep tar # to extract package

dep go14 # used to build go >= 1.5

# Development tools, to build with
cat <<EOF
autoconf
automake
binutils
bison
flex
gcc
gcc-c++
gettext
libtool
make
patch
pkgconfig
redhat-rpm-config
rpm-build
EOF

